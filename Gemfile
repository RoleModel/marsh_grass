source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in marsh_grass.gemspec
gemspec

gem 'rspec', '>= 4.0.0.alpha', '< 5' if ENV['RSPEC_VERSION'] == '4'
gem 'rspec', '~> 3.6' if ENV['RSPEC_VERSION'] == '3'

group :development, :test do
  gem 'rubocop'
  gem 'rspec_junit_formatter'
end
