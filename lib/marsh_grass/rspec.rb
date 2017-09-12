# frozen_string_literal: true

require 'rspec'
require 'timecop'

RSpec.configure do |config|
  config.around(repetitions: true) do |example|
    # Fetch the number of repetitions to try...
    total = example.metadata[:repetitions]
    total.times do |repetition_num|
      # Duplicate the current example, ensuring this tag doesn't trigger...
      repetition = example.duplicate_with(repetitions: false)
      # Add some additional context...
      description = "(Repetition ##{repetition_num + 1} of #{total})"
      context = example.example_group.context(description)
      # Insert the copy into our new context...
      context.add_example(repetition)
    end
    # Remove the original example; it wouldn't hurt to leave, but we're already
    # running it a number of times.
    example.example_group.remove_example(example)
  end

  config.around(time_of_day: true) do |example|
    now = Time.now
    time_of_day = example.metadata[:time_of_day]
    test_segments = time_of_day.is_a?(Array) ? time_of_day : [time_of_day]
    hours_to_run = test_segments.include?(:hours) ? (0..23) : [now.hour]
    minutes_to_run = test_segments.include?(:minutes) ? (0..59) : [now.min]
    seconds_to_run = test_segments.include?(:seconds) ? (0..59) : [now.sec]
    hours_to_run.each do |hour|
      minutes_to_run.each do |minute|
        seconds_to_run.each do |second|
          # Duplicate the current example, ensuring this tag doesn't trigger...
          repetition = example.duplicate_with(time_of_day: false)
          # Freeze time at the specified hour, minute, and/or second.
          Timecop.freeze(now.year, now.month, now.day, hour, minute, second) do
            # Append the time of day to our test description, so we can see it.
            repetition.metadata[:description] += " (Run Time #{hour}:#{minute}:#{second})"
            # We need to run the test within the Timecop.freeze block,
            # in order to actually be affected by Timecop. If we didn't need to
            # be inside this block, we could add the example to a context (as we
            # do for repetitions) and let RSpec run it.
            repetition.run(example.example_group_instance, example.reporter)
          end
        end
      end
    end
    # Remove the original example; it wouldn't hurt to leave, but we're already
    # running it a number of times.
    example.example_group.remove_example(example)
  end

  config.around(surrounding_time: true) do |example|
    now = Time.now
    test_surrounding_time = example.metadata[:surrounding_time]
    hour = test_surrounding_time.fetch(:hour, now.hour)
    minute = test_surrounding_time.fetch(:minute, now.min)
    second = test_surrounding_time.fetch(:second, now.sec)
    # 1000 milliseconds before & after the given time
    test_time_float = Time.local(now.year, now.month, now.day, hour, minute, second).to_f
    (-1000..1000).each do |millisecond|
      # Duplicate the current example, ensuring this tag doesn't trigger...
      repetition = example.duplicate_with(surrounding_time: false)
      test_time = Time.at(test_time_float + millisecond.to_f / 1000)
      # Travel to the specified hour, minute, second, and millisecond, allowing
      # for time to elapse.

      Timecop.travel(test_time) do
        # Append the time of day to our test description, so we can see it.
        repetition.metadata[:description] += " (Run Time #{test_time.strftime('%H:%M:%S:%L')})"
        # We need to run the test within the Timecop.freeze block,
        # in order to actually be affected by Timecop. If we didn't need to
        # be inside this block, we could add the example to a context (as we
        # do for repetitions) and let RSpec run it.
        repetition.run(example.example_group_instance, example.reporter)
      end
    end
    # Remove the original example; it wouldn't hurt to leave, but we're already
    # running it a number of times.
    example.example_group.remove_example(example)
  end

  config.around(elapsed_time: true) do |example|
    # Duplicate the current example, ensuring this tag doesn't trigger...
    # Freeze time at the specified hour, minute, and/or second.
    time_multipliers = example.metadata[:elapsed_time]
    time_multipliers = (1..10) unless time_multipliers.respond_to?(:each)
    time_multipliers.each do |seconds_multiplier|
      repetition = example.duplicate_with(elapsed_time: false)
      Timecop.scale(seconds_multiplier) do
        # Append the time of day to our test description, so we can see it.
        repetition.metadata[:description] += " (Run Speed #{seconds_multiplier}x Slower)"
        # We need to run the test within the Timecop.freeze block,
        # in order to actually be affected by Timecop. If we didn't need to
        # be inside this block, we could add the example to a context (as we
        # do for repetitions) and let RSpec run it.
        repetition.run(example.example_group_instance, example.reporter)
      end
    end
    # Remove the original example; it wouldn't hurt to leave, but we're already
    # running it a number of times.
    example.example_group.remove_example(example)
  end

  config.around(timezones: true) do |example|
    utc = Time.now.utc
    %w[-12 -11 -10 -09 -08 -07 -06 -05 -04 -03 -02 -01 +00 +01 +02 +03 +04 +05 +06 +07 +08 +09 +10 +11 +12 +13 +14].each do |timezone_hour|
      %w[00 30].each do |timezone_minute|
        # Duplicate the current example, ensuring this tag doesn't trigger...
        repetition = example.duplicate_with(timezones: false)
        # Append the time of day to our test description, so we can see it.
        repetition.metadata[:description] += " (Timezone Offset #{timezone_hour}:#{timezone_minute})"
        adjusted_time = Time.new(utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec, "#{timezone_hour}:#{timezone_minute}")
        Timecop.travel(adjusted_time) do
          # We need to run the test within the Timecop.freeze block,
          # in order to actually be affected by Timecop. If we didn't need to
          # be inside this block, we could add the example to a context (as we
          # do for repetitions) and let RSpec run it.
          repetition.run(example.example_group_instance, example.reporter)
        end
      end
    end
    # Remove the original example; it wouldn't hurt to leave, but we're already
    # running it a number of times.
    example.example_group.remove_example(example)
  end
end
