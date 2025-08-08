# frozen_string_literal: true

require 'rspec'
require 'time'
require 'timecop'

RSpec.configure do |config|
  def untag_example(example, tag)
    example.example_group.metadata.delete(tag) if example.metadata[:turnip]
    example.metadata.delete(tag)
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
          timeblock = [hour, minute, second].compact.join(':')
          test_description = "Run Time #{timeblock}: #{shared_description}"
          add_example_to_group(original_example, test_description, timeblock:)

          # To avoid the original example being shown as "PENDING", mark it as executed
          original_example.instance_variable_set(:@executed, true)
        end
      end
    end
  end

  config.before(:each, timeblock: true) do |example|
    now = Time.now
    hour, minute, second = example.metadata[:timeblock].split(':').map(&:to_i)
    # Freeze time at the specified hour, minute, and/or second.
    # We need to run the test within the Timecop.freeze block,
    # in order to actually be affected by Timecop.
    Timecop.freeze(now.year, now.month, now.day, hour, minute, second)
  end

  config.after(:each, timeblock: true) do
    Timecop.return
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
      # We need to run the test within the Timecop.freeze block,
      # in order to actually be affected by Timecop.
      test_time = Time.at(test_time_float + millisecond.to_f / 1000)
      travel_to(test_time) do
        test_description = "Run Time #{test_time.strftime('%H:%M:%S:%L')}: #{shared_description}"
        run_example_or_duplicate(original_example, test_description)
      end
    end
  end

  config.around(time_zones: true) do |original_example|
    shared_description = original_example.metadata[:description]
    untag_example(original_example, :time_zones)

    utc = Time.now.utc
    time_zone_hours = %w[-12 -11 -10 -09 -08 -07 -06 -05 -04 -03 -02 -01 +00 +01 +02 +03 +04 +05 +06 +07 +08 +09 +10 +11 +12 +13 +14]
    time_zone_minutes = %w[00 30]

    time_zone_hours.each do |time_zone_hour|
      time_zone_minutes.each do |time_zone_minute|
        # We need to run the test within the Timecop.freeze block,
        # in order to actually be affected by Timecop.
        adjustment = "#{time_zone_hour}:#{time_zone_minute}"
        adjusted_time = Time.new(utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec, adjustment)
        travel_to(adjusted_time) do
          test_description = "Time Zone Offset #{time_zone_hour}:#{time_zone_minute}: #{shared_description}"
          run_example_or_duplicate(original_example, test_description)
        end
      end
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
end
