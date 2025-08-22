# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MarshGrass do
  it 'has a version number' do
    expect(MarshGrass::VERSION).not_to be nil
  end

  context 'test purity' do
    # Should always pass
    it 'forgets instance variables between tests with repetitions', :repetitions do
      expect(@forgettable_thing).to be nil
      @forgettable_thing = 'something'
    end

    # Should always pass
    it 'forgets instance variables between tests with time_of_day', :time_of_day do
      expect(@forgettable_thing).to be nil
      @forgettable_thing = 'something'
    end

    # Should always pass
    it 'forgets instance variables between tests with surrounding_time', surrounding_time: { hour: 0, minute: 0, second: 0 } do
      expect(@forgettable_thing).to be nil
      @forgettable_thing = 'something'
    end

    # Should always pass
    it 'forgets instance variables between tests with elapsed_time', :elapsed_time do
      expect(@forgettable_thing).to be nil
      @forgettable_thing = 'something'
    end

    # Should always pass
    it 'forgets instance variables between with time_zones', :time_zones do
      expect(@forgettable_thing).to be nil
      @forgettable_thing = 'something'
    end
  end

  context 'running tests a certain number of times' do
    repetition_5_count = 0
    repetition_1000_count = 0
    after(:all) do
      # assert that the repetitions were run
      expect(repetition_5_count).to eq 5
      expect(repetition_1000_count).to eq 1000
    end

    # Should run 5x
    it 'runs the specified number of repetitions', repetitions: 5 do
      repetition_5_count += 1
      expect(repetition_5_count).to be <= 5
    end

    # Should run 1000x
    it 'allows running a default number of repetitions', :repetitions do
      repetition_1000_count += 1
      expect(repetition_1000_count).to be <= 1000
    end
  end

  context 'running tests at a certain time of day' do
    hours_to_run = []
    minutes_to_run = []
    seconds_to_run = []
    hours_and_minutes_to_run = []
    minutes_and_seconds_to_run = []
    hours_minutes_and_seconds_to_run = []
    after(:all) do
      # assert that the hours were run
      expect(hours_to_run.length).to eq 24
      expect(hours_to_run).to match_array (0..23).to_a
      # assert that the minutes were run
      expect(minutes_to_run.length).to eq 60
      expect(minutes_to_run).to match_array (0..59).to_a
      # assert that the seconds were run
      expect(seconds_to_run.length).to eq 60
      expect(seconds_to_run).to match_array (0..59).to_a

      def make_time(first, second)
        [first.to_s.rjust(2, '0'), second.to_s.rjust(2, '0')].join(':')
      end

      # assert that the hours & minutes were run
      expect(hours_and_minutes_to_run.length).to eq 24 * 60
      expected_hours_and_minutes = (0..23).to_a.map { |h| (0..59).map { |m| make_time(h, m) } }.flatten
      expect(hours_and_minutes_to_run).to match_array expected_hours_and_minutes
      # assert that the minutes & seconds were run
      expect(minutes_and_seconds_to_run.length).to eq 60 * 60
      expected_minutes_and_seconds = (0..59).to_a.map { |m| (0..59).map { |s| make_time(m, s) } }.flatten
      expect(minutes_and_seconds_to_run).to match_array expected_minutes_and_seconds
      # assert that the hours, minutes & seconds were run
      # expect(hours_minutes_and_seconds_to_run.length).to eq 24 * 60 * 60
      # expected_hours_minutes_and_seconds = expected_hours_and_minutes.map { |hm| (0..59).map { |s| make_time(hm, s) } }.flatten
      # expect(hours_minutes_and_seconds_to_run).to match_array expected_hours_minutes_and_seconds
    end

    # Should run 24x and have all hours of the day
    it 'allows testing against an iteration of hours', time_of_day: :hours do
      hours_to_run << Time.now.hour
    end

    # Should run 60x and have all minutes of the hour
    it 'allows testing against an iteration of minutes', time_of_day: :minutes do
      minutes_to_run << Time.now.min
    end

    # Should run 60x and have all seconds of the minute
    it 'allows testing against an iteration of seconds', time_of_day: :seconds do
      seconds_to_run << Time.now.sec
    end

    # Should run (24 * 60) = 1440x and have all hours and minutes of the day
    it 'allows testing against an iteration of hours and minutes', time_of_day: %i[hours minutes] do
      hours_and_minutes_to_run << Time.now.strftime('%H:%M')
    end

    # Should run (60 * 60) = 3600x and have all minutes and seconds of the day
    it 'allows testing against an iteration of minutes and seconds', time_of_day: %i[minutes seconds] do
      minutes_and_seconds_to_run << Time.now.strftime('%M:%S')
    end

    # Should run (24 * 60 * 60) = 86400x and have all hours, minutes, and seconds of the day
    # This test is too slow to run by default, so it is commented out.
    xit 'allows testing against an iteration of hours, minutes, and seconds', time_of_day: %i[hours minutes seconds] do
      hours_minutes_and_seconds_to_run << Time.now.strftime('%H:%M:%S')
    end
  end

  context 'running tests surrounding a particular time' do
    millisecond_hundreths = []
    after(:all) do
      # assert that the repetitions were run
      expect(millisecond_hundreths.length).to eq 2001
      expect(millisecond_hundreths.uniq.sort).to eq (0..9).to_a.map(&:to_s)
    end

    # Should run 1000x before passed time
    # Should run 1x 'on' the particular time
    # Should run 1000x after passed time
    it 'allows testing for time surrounding midnight', surrounding_time: { hour: 0, minute: 0, second: 0 } do
      millisecond_hundreths << Time.now.strftime('%L')[0]
    end
  end

  context 'running tests for variable elapsed time' do
    elapsed_seconds_true = []
    elapsed_seconds_range = []
    after(:all) do
      # assert that the repetitions were run
      expect(elapsed_seconds_true.length).to eq 10
      # should be 10 but depends on the milliseconds when started and test runtime
      # using 5 as a reasonable minimum to avoid false positives
      expect(elapsed_seconds_true.uniq.length).to be > 5
      expect(elapsed_seconds_range.length).to eq 2
      # could be 1 & 2 or 1 & 3, depending on the milliseconds when started and test runtime
      expect(elapsed_seconds_range.uniq.length).to eq 2
    end

    # Should run 10x
    it 'allows testing for time-dependent methods across default duration multipliers', :elapsed_time do
      time_one = Time.now.to_i
      sleep 1
      time_two = Time.now.to_i
      elapsed_seconds_true << time_two - time_one
    end

    # Should run 2x
    it 'allows testing for specified duration multipliers', elapsed_time: (1..2) do
      time_one = Time.now.to_i
      sleep 1
      time_two = Time.now.to_i
      elapsed_seconds_range << time_two - time_one
    end
  end

  context 'running tests for variations in timezone' do
    timezone_hours = []
    after(:all) do
      # assert that the repetitions were run
      expect(timezone_hours.length).to eq 34
      offsets = %w[+00:00 +01:00 +02:00 +03:00 +03:30 +04:00 +04:30 +05:00 +05:30 +05:45 +06:00 +06:30 +07:00 +08:00 +09:00 +09:30 +10:00 +11:00 +12:00 +12:45 +13:00 -01:00 -02:00 -03:00 -03:30 -04:00 -05:00 -06:00 -07:00 -08:00 -09:00 -10:00 -11:00 -12:00]
      expect(timezone_hours.uniq.sort).to eq offsets
    end

    # Should run 34x
    it 'allows testing for all timezone variations', :time_zones do
      timezone_hours << Time.zone.formatted_offset
    end
  end

  xcontext 'combining test scenarios' do
    # Should run (10 * 24) = 240x and fail 66%
    it 'runs repetitions of iterations on hours', repetitions: 10, time_of_day: :hours do
      expect(rand(1..3)).to eq 1
    end

    # Should run (2 * 1000) = 2000x before chosen time and fail last ~ (3 * 50)x
    # Should run 2x at chosen time and pass
    # Should run (2 * 1000) = 2000x after chosen time and never fail
    it 'runs slowly and time approaches midnight', surrounding_time: { hour: 0, minute: 0, second: 0 } do
      now = Time.now
      expect { sleep 0.05 }.not_to change { Time.now.day }.from(now.day)
    end
  end
end
