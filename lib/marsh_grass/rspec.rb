# frozen_string_literal: true

require 'rspec'
require 'time'
require 'timecop'

RSpec.configure do |config|
  def untag_example(example, tag)
    example.example_group.metadata.delete(tag) if example.metadata[:turnip]
    return_value = example.metadata[tag]
    example.metadata[tag] = false # Set to false to avoid recursive nested repetitions
    return_value
  end

  def add_example_to_group(original_example, test_description, metadata_overrides = {})
    repetition = original_example.duplicate_with(metadata_overrides)
    repetition.metadata[:description] = test_description
    original_example.example_group.context.add_example(repetition)
  end

  def run_example_or_duplicate(original_example, test_description)
    if !original_example.executed?
      # Let the original example be the first repetition that is printed
      original_example.metadata[:description] = test_description
      original_example.run
    else
      add_example_to_group(original_example, test_description)
    end
  end

  config.around(time_of_day: true) do |original_example|
    shared_description = original_example.metadata[:description]

    now = Time.now
    time_of_day = untag_example(original_example, :time_of_day)
    test_segments = time_of_day.is_a?(Array) ? time_of_day : [time_of_day]
    test_segments = [:hours] if test_segments == [true]
    hours_to_run = test_segments.include?(:hours) ? (0..23) : [now.hour]
    minutes_to_run = test_segments.include?(:minutes) ? (0..59) : [now.min]
    seconds_to_run = test_segments.include?(:seconds) ? (0..59) : [now.sec]

    hours_to_run.each do |hour|
      minutes_to_run.each do |minute|
        seconds_to_run.each do |second|
          frozen_time = Time.new(now.year, now.month, now.day, hour, minute, second)
          test_description = "Run Time #{frozen_time.strftime('%H:%M:%S')}: #{shared_description}"
          add_example_to_group(original_example, test_description, frozen_time: frozen_time.to_s)

          # To avoid the original example being shown as "PENDING", mark it as executed
          original_example.instance_variable_set(:@executed, true)
        end
      end
    end
  end

  config.around(surrounding_time: true) do |original_example|
    shared_description = original_example.metadata[:description]

    now = Time.now
    surrounding_time = untag_example(original_example, :surrounding_time)
    hour = surrounding_time.fetch(:hour, now.hour)
    minute = surrounding_time.fetch(:minute, now.min)
    second = surrounding_time.fetch(:second, now.sec)
    # 1000 milliseconds before & after the surrounding time
    test_time_float = Time.local(now.year, now.month, now.day, hour, minute, second).to_f

    (-1000..1000).each do |millisecond|
      # Travel to the specified hour, minute, second, and millisecond, allowing
      # for time to elapse.
      moving_time = Time.at(test_time_float + millisecond.to_f / 1000)
      test_description = "Run Time #{moving_time.strftime('%H:%M:%S:%L')}: #{shared_description}"
      moving_time_string = moving_time.strftime('%Y-%m-%d %H:%M:%S.%L %z')
      add_example_to_group(original_example, test_description, moving_time: moving_time_string)

      # To avoid the original example being shown as "PENDING", mark it as executed
      original_example.instance_variable_set(:@executed, true)
    end
  end

  config.around(elapsed_time: true) do |original_example|
    shared_description = original_example.metadata[:description]

    time_multipliers = untag_example(original_example, :elapsed_time)
    time_multipliers = (1..10) unless time_multipliers.respond_to?(:each)

    time_multipliers.each do |seconds_multiplier|
      test_description = "Run Speed #{seconds_multiplier}x Slower: #{shared_description}"
      add_example_to_group(original_example, test_description, scaling_time: seconds_multiplier.to_s)

      # To avoid the original example being shown as "PENDING", mark it as executed
      original_example.instance_variable_set(:@executed, true)
    end
  end

  config.around(time_zones: true) do |original_example|
    shared_description = original_example.metadata[:description]
    untag_example(original_example, :time_zones)

    timezone_hash = ActiveSupport::TimeZone.all.each_with_object({}) do |tz, memo|
      memo[tz.formatted_offset] = tz.name
    end

    timezone_hash.each do |time_zone_offset, time_zone_name|
      test_description = "Time Zone Offset #{time_zone_offset}: #{shared_description}"
      add_example_to_group(original_example, test_description, time_zone: time_zone_name)

      # To avoid the original example being shown as "PENDING", mark it as executed
      original_example.instance_variable_set(:@executed, true)
    end
  end

  config.around(repetitions: true) do |original_example|
    shared_description = original_example.metadata[:description]

    repetitions = untag_example(original_example, :repetitions)
    total = repetitions.is_a?(Integer) ? repetitions : 1000

    (1..total).each do |count|
      test_description = "Repetition #{count} of #{total}: #{shared_description}"
      run_example_or_duplicate(original_example, test_description)
    end
  end

  config.before(:each, frozen_time: true) do |example|
    time = Time.parse(example.metadata[:frozen_time])
    # Freeze time at the specified hour, minute, and/or second.
    Timecop.freeze(time)
  end

  config.after(:each, frozen_time: true) do
    Timecop.return
  end

  config.before(:each, moving_time: true) do |example|
    time = Time.parse(example.metadata[:moving_time])
    # Travel to time at the specified hour, minute, and/or second.
    Timecop.travel(time)
  end

  config.after(:each, moving_time: true) do
    Timecop.return
  end

  config.before(:each, scaling_time: true) do |example|
    time_multiplier = example.metadata[:scaling_time].to_i
    # Scale time by the specified multiplier.
    Timecop.scale(time_multiplier)
  end

  config.after(:each, scaling_time: true) do
    Timecop.return
  end

  config.before(:each, time_zone: true) do |example|
    ENV['OLD_TIME_ZONE'] = Time.zone&.name
    # Switch to the given time zone for the duration of the example.
    Time.zone = example.metadata[:time_zone]
  end

  config.after(:each, time_zone: true) do
    Time.zone = ENV['OLD_TIME_ZONE']
  end
end
