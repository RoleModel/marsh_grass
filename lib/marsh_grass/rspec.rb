# frozen_string_literal: true

require 'rspec'

RSpec.configure do |config|
  config.around(repetitions: true) do |example|
    # Fetch the number of repetitions to try...
    total = example.metadata[:repetitions]
    total.times do |repetition_num|
      # Duplicate the current example, ensuring this tag doesn't trigger...
      repetition = example.duplicate_with(repetitions: false)
      # Add some additional context...
      description = "(Repetition ##{repetition_num} of #{total})"
      context = example.example_group.context(description)
      # Insert the copy into our new context...
      context.add_example(repetition)
    end
    # Remove the original example; it wouldn't hurt to leave, but we're already
    # running it a number of times.
    example.example_group.remove_example(example)
  end
end
