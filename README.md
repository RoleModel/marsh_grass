# MarshGrass

Finally! A way to examine the behavior of intermittent failures in RSpec.

This gem allows you to subject an intermittently failing test to a variety of circumstances in an attempt to discern what combination of events leads to failure.

## Background

Intermittent failures are challenging because the failure conditions are more difficult to pinpoint than with tests that fail 100% of the time.

Intermittent failures are also more likely to make it into production. They often pass during CI testing and code review and then crop up days or weeks later.

In programming, there is no such thing as a "random" failure. Every intermittent failure actually fails consistently, every single time... under the right set of circumstances. Perhaps your test only fails on Friday afternoons. Or, 10% of the time under race conditions. We once had a test that failed on every power of 2 run: on the 2nd, 4th, 8th, 16th run, etc. The more we ran it, the more elusive it became.

Often, the first step in fixing such a failure is to make it fail consistently. That way, as you change your code, you can use the test to confirm when you've fixed the root cause. After all, that is the purpose of the test!

## Features
This gem subjects a given test to the following circumstances:
- repetitions
- range of speeds in execution
- execution at all times of day
- execution in all time zones
- execution at all the milliseconds surrounding a particular time of day

In our experience, repetitions is the option we use the most often. It gives the broadest feedback and is very effective at uncovering race conditions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'marsh_grass'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install marsh_grass

## Usage
Feature use:
- N repetitions (default: 1000, or specify integer)
- Times of day (default: all hours, minutes, seconds or specify :hours, :minutes, :seconds)
- Time zones (executes against each time zone offset from ActiveSupport::TimeZone)
- Elapsed time during test execution (default: (1..10) execution slow-down multipliers or specify range)
- Surrounding time, i.e., clock change over during the test (must specify hour: <integer>, minute: <integer>, second: <integer>)

Surrounding time runs test at every millisecond from 1 sec before to 1 sec after specified time. This is particularly useful for discerning rate of failure near and at midnight.

### Examples
Simple examples:
```ruby
it 'uses default repetitions', :repetitions do
 ...
end

it 'uses specific repetitions', repetitions: 20 do
  ...
end

it 'uses just hours for default surrounding_time', :time_of_day do
 ...
end

it 'uses each hour of day', time_of_day: :hours do
  ...
end

it 'uses each hour and minute of the day', time_of_day: [:hours, :minutes] do
 ...
end

it 'uses each second of current minute', time_of_day: :seconds do
  ...
end

it 'uses current time for default surrounding_time', :surrounding_time do
 ...
end

it 'uses each millisecond around hour of day', surrounding_time: { hour: 17 } do
  ...
end

it 'uses each millisecond around specified time (noon)', surrounding_time: { hour: 12, minute: 0, second: 0 } do
 ...
end

it 'uses 10 different speeds for default elapsed_time', :elapsed_time do
  ...
end

it 'uses array of different speeds for elapsed_time', elapsed_time: [1, 5, 10] do
  ...
end

it 'uses range of different speeds for elapsed_time', elapsed_time: (1..5) do
  ...
end

it 'uses 34 different timezones for default time_zones', :time_zones do
  ...
end

it 'uses single named timezone for time_zone (singular)', time_zone: 'Eastern Time (US & Canada)' do
  ...
end

it 'uses a specific frozen time with a string', frozen_time: '2025-08-22 17:00:00' do
  ...
end

it 'uses a specific frozen time with a Time', frozen_time: Time.new(2025, 8, 22, 17) do
  ...
end

it 'uses a specific moving time with a string', moving_time: '2025-08-22 17:00:00' do
  ...
end

it 'uses a specific moving time with a Time', moving_time: Time.new(2025, 8, 22, 17) do
  ...
end

it 'uses a specific time scalar', scaling_time: 8 do
  ...
end

```
[Further Examples](./spec/marsh_grass_spec.rb) of tests using each feature.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/RoleModel/marsh_grass.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
