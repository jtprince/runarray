#!/usr/bin/env ruby

require 'rsruby'
require 'yaml'

# plots the output of spec/benchmark.rb

def rnd(num, places)
  "%.#{places}f" % num
end

file = ARGV.shift
abort "need file from spec/benchmark.rb to proceed!" unless file
hsh = YAML.load_file(file)

r = RSRuby.instance
r.png("alltogether.png", 1000, 1000)

r.par(:mfrow => [hsh.size,1])
r.par(:las => 1)


#'mar' A numerical vector of the form 'c(bottom, left, top, right)'
#          which gives the number of lines of margin to be specified on
#          the four sides of the plot. The default is 'c(5, 4, 4, 2) +
#          0.1'.
r.par(:mar => [3,20,3,1])

hsh.each do |name, pairs|
     
  labels = []
  heights = []
  pairs.each do |label, height|
    labels << label.gsub('@','')
    heights << height
  end
  r.barplot(heights, :beside => true, :names_arg => labels, :horiz => true, :xlim => [0, 1.75])
  pairs.each_with_index do |lh, i|
    r.text(lh.last+0.01, i+1+(0.2*i), rnd(lh.last,3).to_s, :adj => [0,1])
  end
  # we should just use a text object 
  #r.title(:ylab=> name, :outer => false, :line => 15)
  r.mtext(:text=> name, :side => 2, :padj => -5, :line => 1)
end
r.title(:xlab => 'seconds', :outer => true)
r.eval_R("dev.off()")
