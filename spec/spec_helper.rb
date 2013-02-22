
require 'rubygems'
require 'rspec'


# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
#Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.color_enabled = true
  config.tty = true
  config.formatter = :documentation  # :progress, :html, :textmate
  #config.formatter = :progress # :progress, :html, :textmate
end
