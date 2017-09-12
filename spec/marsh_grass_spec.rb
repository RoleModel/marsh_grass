# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MarshGrass do
  it 'has a version number' do
    expect(MarshGrass::VERSION).not_to be nil
  end

  context 'running tests a certain number of times' do
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

  context 'running tests for variable elapsed time' do
    it 'allows testing for time-dependent methods across default duration multipliers', :elapsed_time do
      expect { sleep 0.2 }.to change { Time.now.to_i }.by(1)
    end

    it 'allows testing for specified duration multipliers', elapsed_time: (1..2) do
      expect { sleep 1 }.to change { Time.now.to_i }.by(1)
    end
  end
end
