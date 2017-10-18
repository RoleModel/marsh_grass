# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MarshGrass do
  it 'has a version number' do
    expect(MarshGrass::VERSION).not_to be nil
  end

  context 'running tests a certain number of times' do
    # Should run 20x and fail ~ 14x
    it 'allows specifying a number of repetitions', repetitions: 20 do
      expect(rand(1..3)).to eq 1
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

    # Should run (24 * 60)x and fail 1x
    it 'allows testing against an iteration of hours and minutes', time_of_day: [:hours, :minutes] do
      expect(Time.now.strftime('%H:%M')).not_to eq('10:25')
    end

    # Should run (60 * 60)x and fail 1x
    it 'allows testing against an iteration of minutes and seconds', time_of_day: [:minutes, :seconds] do
      expect(Time.now.strftime('%M:%S')).not_to eq('25:44')
    end

    # Should run (24 * 60 * 60)x and fail 1x
    it 'allows testing against an iteration of hours, minutes, and seconds', time_of_day: [:hours, :minutes, :seconds] do
      expect(Time.now.strftime('%H:%M:%S')).not_to eq('10:25:44')
    end
  end

  context 'running tests surrounding a particular time' do
    # Should run 1000x before passed time and fail last ~ 50x
    # Should run 1000x after passed time and never fail
    it 'allows testing for time surrounding midnight', surrounding_time: { hour: 0, minute: 0, second: 0 } do
      now = Time.now
      expect { sleep 0.05 }.not_to change { Time.now.day }.from(now.day)
    end
  end

  context 'running tests for variable elapsed time' do
    # Should run 10x and fail ?x
    # (depending on where in the milliseconds you run, does 0.2 push it over to next second?)
    it 'allows testing for time-dependent methods across default duration multipliers', :elapsed_time do
      expect { sleep 0.2 }.to change { Time.now.to_i }.by(1)
    end

    # Should run 2x and fail 1x
    it 'allows testing for specified duration multipliers', elapsed_time: (1..2) do
      expect { sleep 1 }.to change { Time.now.to_i }.by(1)
    end
  end

  context 'running tests for variations in timezone' do
    it 'allows testing for all timezone variations', :timezones do
      expect(Time.now.hour).not_to eq(1)
    end
  end

  context 'combining test scenarios' do
    # Should run (20 * 24)x and fail 66%
    it 'runs repetitions of iterations on hours', repetitions: 20, time_of_day: :hours do
      expect(rand(1..3)).to eq 1
    end

    # Should run (2 * 1000)x before passed time and fail last ~ (3 * 50)x
    # Should run (2 * 1000)x after passed time and never fail
    it 'runs slowly and time approaches midnight', elapsed_time: (1..2), surrounding_time: { hour: 0, minute: 0, second: 0 } do
      now = Time.now
      expect { sleep 0.05 }.not_to change { Time.now.day }.from(now.day)
    end
  end
end
