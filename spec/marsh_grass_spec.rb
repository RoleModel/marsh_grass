# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MarshGrass do
  it 'has a version number' do
    expect(MarshGrass::VERSION).not_to be nil
  end

  it 'does something useful', repetitions: 20 do
    expect(rand(1..3)).to eq 1
  end
end
