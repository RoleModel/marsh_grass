# frozen_string_literal: true

require 'rspec'
require 'timecop'
require 'pry'

RSpec.configure do |config|

  config.around(repetitions: true) do |original_example|
    # Fetch the number of repetitions to try...
    repetitions = original_example.metadata[:repetitions]
    total = repetitions.is_a?(Integer) ? repetitions : 1000
    # Add repetition count to description
    def modify_description(test, count, total)
      test.metadata[:description] = "Repetition #{count} of #{total}: #{test.metadata[:description]}"
    end

    (1..total).each do |count|
      # Let the original example be the final repetition
      example = if count < total
        original_example.duplicate_with(repetitions: false) # ensure tag does not trigger
      else
        original_example
      end
      modify_description(example, count, total)
      example.run(original_example.example_group_instance, original_example.reporter)
    end
  end

  config.around(time_of_day: true) do |original_example|
    now = Time.now
    time_of_day = original_example.metadata[:time_of_day]
    test_segments = time_of_day.is_a?(Array) ? time_of_day : [time_of_day]
    test_segments = [:hours] if test_segments == [true]
    hours_to_run = test_segments.include?(:hours) ? (0..23) : [now.hour]
    minutes_to_run = test_segments.include?(:minutes) ? (0..59) : [now.min]
    seconds_to_run = test_segments.include?(:seconds) ? (0..59) : [now.sec]

    total = hours_to_run.size * minutes_to_run.size * seconds_to_run.size

    # Add time of day to our test description
    def modify_description(test, hour, minute, second)
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
            example = if run_count < total
              original_example.duplicate_with(time_of_day: false) # ensure tag does not trigger
            else
              original_example
            end
            modify_description(example, hour, minute, second)
            example.run(original_example.example_group_instance, original_example.reporter)
          end
        end
      end
    end
  end

  config.around(surrounding_time: true) do |original_example|
    now = Time.now
    surrounding_time = original_example.metadata[:surrounding_time]
    hour = surrounding_time.fetch(:hour, now.hour)
    minute = surrounding_time.fetch(:minute, now.min)
    second = surrounding_time.fetch(:second, now.sec)
    # 1000 milliseconds before & after the surrounding time
    test_time_float = Time.local(now.year, now.month, now.day, hour, minute, second).to_f

    # Add exact time to our test description
    def modify_description(test, time)
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
        example = if millisecond < 1000
          original_example.duplicate_with(surrounding_time: false) # ensure tag doesn't trigger
        else
          original_example
        end
        modify_description(example, test_time)
        example.run(original_example.example_group_instance, original_example.reporter)
      end
    end
  end

  config.around(elapsed_time: true) do |original_example|
    # Duplicate the current original_example, ensuring this tag doesn't trigger...
    # Freeze time at the specified hour, minute, and/or second.
    time_multipliers = original_example.metadata[:elapsed_time]
    time_multipliers = (1..10) unless time_multipliers.respond_to?(:each)
    time_multipliers.each do |seconds_multiplier|
      repetition = original_example.duplicate_with(elapsed_time: false)
      Timecop.scale(seconds_multiplier) do
        # Append the time of day to our test description, so we can see it.
        repetition.metadata[:description] += " (Run Speed #{seconds_multiplier}x Slower)"
        # We need to run the test within the Timecop.freeze block,
        # in order to actually be affected by Timecop. If we didn't need to
        # be inside this block, we could add the original_example to a context (as we
        # do for repetitions) and let RSpec run it.
        repetition.run(original_example.example_group_instance, original_example.reporter)
      end
    end
    # Remove the original original_example; it wouldn't hurt to leave, but we're already
    # running it a number of times.
    original_example.example_group.remove_example(original_example)
  end

  config.around(timezones: true) do |original_example|
    utc = Time.now.utc
    %w[-12 -11 -10 -09 -08 -07 -06 -05 -04 -03 -02 -01 +00 +01 +02 +03 +04 +05 +06 +07 +08 +09 +10 +11 +12 +13 +14].each do |timezone_hour|
      %w[00 30].each do |timezone_minute|
        # Duplicate the current original_example, ensuring this tag doesn't trigger...
        repetition = original_example.duplicate_with(timezones: false)
        # Append the time of day to our test description, so we can see it.
        repetition.metadata[:description] += " (Timezone Offset #{timezone_hour}:#{timezone_minute})"
        adjusted_time = Time.new(utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec, "#{timezone_hour}:#{timezone_minute}")
        Timecop.travel(adjusted_time) do
          # We need to run the test within the Timecop.freeze block,
          # in order to actually be affected by Timecop. If we didn't need to
          # be inside this block, we could add the original_example to a context (as we
          # do for repetitions) and let RSpec run it.
          repetition.run(original_example.example_group_instance, original_example.reporter)
        end
      end
    end
    # Remove the original original_example; it wouldn't hurt to leave, but we're already
    # running it a number of times.
    original_example.example_group.remove_example(example)
  end
end
