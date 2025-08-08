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
    # Should run 24x and fail 1x
    it 'allows testing against an iteration of hours', time_of_day: :hours do
      expect(Time.now.hour).not_to eq(10)
    end

    # Should run 60x and fail 1x
    it 'allows testing against an iteration of minutes', time_of_day: :minutes do
      expect(Time.now.min).not_to eq(25)
    end

    # Should run 60x and fail 1x
    it 'allows testing against an iteration of seconds', time_of_day: :seconds do
      expect(Time.now.sec).not_to eq(44)
    end

    # Should run (24 * 60) = 1440x and fail 1x
    it 'allows testing against an iteration of hours and minutes', time_of_day: [:hours, :minutes] do
      expect(Time.now.strftime('%H:%M')).not_to eq('10:25')
    end

    # Should run (60 * 60) = 3600x and fail 1x
    it 'allows testing against an iteration of minutes and seconds', time_of_day: [:minutes, :seconds] do
      expect(Time.now.strftime('%M:%S')).not_to eq('25:44')
    end

    # Should run (24 * 60 * 60) = 86400x and fail 1x
    it 'allows testing against an iteration of hours, minutes, and seconds', time_of_day: [:hours, :minutes, :seconds] do
      expect(Time.now.strftime('%H:%M:%S')).not_to eq('10:25:44')
    end
  end

  context 'running tests surrounding a particular time' do
    # Should run 1000x before passed time and fail last ~ 50x
    # Should run 1x 'on' the particular time and pass
    # Should run 1000x after passed time and never fail
    it 'allows testing for time surrounding midnight', surrounding_time: { hour: 0, minute: 0, second: 0 } do
      now = Time.now
      expect { sleep 0.05 }.not_to change { Time.now.day }.from(now.day)
    end
  end

  context 'combining test scenarios' do
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
