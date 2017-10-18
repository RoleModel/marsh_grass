# frozen_string_literal: true

require 'rspec'
require 'timecop'
require 'pry'

RSpec.configure do |config|
  config.around(time_of_day: true) do |original_example|
    now = Time.now
    time_of_day = original_example.metadata.delete(:time_of_day)
    test_segments = time_of_day.is_a?(Array) ? time_of_day : [time_of_day]
    test_segments = [:hours] if test_segments == [true]
    hours_to_run = test_segments.include?(:hours) ? (0..23) : [now.hour]
    minutes_to_run = test_segments.include?(:minutes) ? (0..59) : [now.min]
    seconds_to_run = test_segments.include?(:seconds) ? (0..59) : [now.sec]

    total = hours_to_run.size * minutes_to_run.size * seconds_to_run.size

    def describe_time_of_day(test, hour, minute, second)
      test.metadata[:description] = "Run Time #{hour}:#{minute}:#{second}: #{test.metadata[:description]}"
    end

    run_count = 0
    hours_to_run.each do |hour|
      minutes_to_run.each do |minute|
        seconds_to_run.each do |second|
          run_count += 1
          # Freeze time at the specified hour, minute, and/or second.
          # We need to run the test within the Timecop.freeze block,
          # in order to actually be affected by Timecop.
          Timecop.freeze(now.year, now.month, now.day, hour, minute, second) do
            # Let the original example be the final repetition
            last_run = run_count == total
            example = last_run ? original_example : original_example.duplicate_with
            # Run example with a helpful description
            describe_time_of_day(example, hour, minute, second)
            example.run(original_example.example_group_instance, original_example.reporter)
          end
        end
      end
    end
  end

  config.around(surrounding_time: true) do |original_example|
    now = Time.now
    surrounding_time = original_example.metadata.delete(:surrounding_time)
    hour = surrounding_time.fetch(:hour, now.hour)
    minute = surrounding_time.fetch(:minute, now.min)
    second = surrounding_time.fetch(:second, now.sec)
    # 1000 milliseconds before & after the surrounding time
    test_time_float = Time.local(now.year, now.month, now.day, hour, minute, second).to_f

    def describe_exact_time(test, time)
      test.metadata[:description] = "Run Time #{time.strftime('%H:%M:%S:%L')}: #{test.metadata[:description]}"
    end

    (-1000..1000).each do |millisecond|
      # Travel to the specified hour, minute, second, and millisecond, allowing
      # for time to elapse.
      # We need to run the test within the Timecop.freeze block,
      # in order to actually be affected by Timecop.
      test_time = Time.at(test_time_float + millisecond.to_f / 1000)
      Timecop.travel(test_time) do
        # Let the original example be the final repetition
        last_run = millisecond == 1000
        example = last_run ? original_example : original_example.duplicate_with
        # Run example with a helpful description
        describe_exact_time(example, test_time)
        example.run(original_example.example_group_instance, original_example.reporter)
      end
    end
  end

  config.around(elapsed_time: true) do |original_example|
    def describe_time_elapsed(test, scale)
      test.metadata[:description] = "Run Speed #{scale}x Slower: #{test.metadata[:description]}"
    end

    # Freeze time at the specified hour, minute, and/or second.
    # We need to run the test within the Timecop.freeze block,
    # in order to actually be affected by Timecop.
    time_multipliers = original_example.metadata.delete(:elapsed_time)
    time_multipliers = (1..10) unless time_multipliers.respond_to?(:each)
    time_multipliers.each do |seconds_multiplier|
      Timecop.scale(seconds_multiplier) do
        # Let the original example be the final repetition
        last_run = seconds_multiplier == time_multipliers.last
        example = last_run ? original_example : original_example.duplicate_with
        # Run example with a helpful description
        describe_time_elapsed(example, seconds_multiplier)
        example.run(original_example.example_group_instance, original_example.reporter)
      end
    end
  end

  config.around(time_zones: true) do |original_example|
    original_example.metadata.delete(:time_zones)

    utc = Time.now.utc
    time_zone_hours = %w[-12 -11 -10 -09 -08 -07 -06 -05 -04 -03 -02 -01 +00 +01 +02 +03 +04 +05 +06 +07 +08 +09 +10 +11 +12 +13 +14]
    time_zone_minutes = %w[00 30]

    def describe_time_zone(test, time_zone_hour, time_zone_minute)
      test.metadata[:description] = "Time Zone Offset #{time_zone_hour}:#{time_zone_minute}: #{test.metadata[:description]}"
    end

    total = time_zone_hours.size * time_zone_minutes.size

    time_zone_hours.each.with_index do |time_zone_hour, hour_index|
      time_zone_minutes.each.with_index(1) do |time_zone_minute, minute_index|
        adjustment = "#{time_zone_hour}:#{time_zone_minute}"
        adjusted_time = Time.new(utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec, adjustment)
        # We need to run the test within the Timecop.freeze block,
        # in order to actually be affected by Timecop.
        Timecop.travel(adjusted_time) do
          # Let the original example be the final repetition
          last_run = (hour_index * 2) + minute_index == total
          example = last_run ? original_example : original_example.duplicate_with
          # Run example with a helpful description
          describe_time_zone(example, time_zone_hour, time_zone_minute)
          example.run(original_example.example_group_instance, original_example.reporter)
        end
      end
    end
  end

  config.around(repetitions: true) do |original_example|
    repetitions = original_example.metadata.delete(:repetitions)
    total = repetitions.is_a?(Integer) ? repetitions : 1000

    def describe_repetition_count(test, count, total)
      test.metadata[:description] = "Repetition #{count} of #{total}: #{test.metadata[:description]}"
    end

    (1..total).each do |count|
      # Let the original example be the final repetition
      last_run = count == total
      example = last_run ? original_example : original_example.duplicate_with
      # Run example with a helpful description
      describe_repetition_count(example, count, total)
      example.run(original_example.example_group_instance, original_example.reporter)
    end
  end
end
