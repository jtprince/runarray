
require 'rubygems'
require 'bacon'

def xit(*args, &block)
  puts "SKIPPING: #{args}"
end

Bacon.summary_on_exit
