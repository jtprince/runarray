
require 'rubygems'
require 'minitest/spec'

MiniTest::Unit.autorun


def xit(*args, &block)
  puts "SKIPPING: #{args}"
end
