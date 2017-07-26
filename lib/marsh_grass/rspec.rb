# frozen_string_literal: true

require 'rspec'

RSpec.configure do |config|
  config.around(repetitions: true) do |example|
    # Fetch the number of repetitions to try...
    total = example.metadata[:repetitions]
    total.times do |repetition_num|
      # Duplicate the current example, ensuring this tag doesn't trigger...
      repetition = example.duplicate_with(repetitions: false)
      # Update the description with some additional context...
      repetition.metadata[:description] += " (##{repetition_num})"
      # Run the new copy within the original context / reporter...
      repetition.run(example.example_group_instance, example.reporter)
    end
    # Remove the original example; it wouldn't hurt to leave, but we're already
    # running it a number of times.
    example.example_group.remove_example(example)
  end
end
