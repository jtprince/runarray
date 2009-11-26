require 'benchmark'
require 'narray'
require 'orderedhash'

Len = 1000000
NArr = NArray[0...Len].to_f
Arr = (0...Len).to_a

class BM
  attr_accessor :label

  # returns the BM object
  def self.bm(label, &block)
    obj = new(label)
    block.call(obj)
    obj.bmbm
    obj
  end

  def initialize(label, measurements=nil)
    @label = label
    @measurements = measurements || OrderedHash.new
  end
  
  def bmbm
    # fill in any ones without a block with the label
    @measurements.each do |label, blk|
      if blk.nil?
        @measurements[label] = lambda { eval label }
      end
    end
    # rehearsal
    @measurements.each do |label, blk|
      Benchmark.measure &blk
    end
    @measurements.each do |label, blk|
      @measurements[label] = Benchmark.measure(&blk).utime
    end
  end

  def time(label, &block)
    @measurements[label] = block
  end

  # sorts by smallest times
  def to_pairs(sort=true)
    @measurements.sort_by {|k,time| time }
  end
end

# Intel(R) Core(TM)2 Duo CPU     E6550  @ 2.33GHz
# Linux fortius 2.6.28-16-generic #55-Ubuntu SMP Tue Oct 20 19:48:24 UTC 2009 i686 GNU/Linux

results = []
results << BM.bm("initialize one-million floats 0...1e6") do |bm|
  bm.time("(0...Len).to_a")
  bm.time("(0...Len).to_a.map{|v| v.to_f}")
  bm.time("(0...Len).to_a")
  bm.time("NArray[0...Len].to_f")
  bm.time("NArray.float(Len).indgen!")
  bm.time("NArray.to_na((0...Len).to_a).to_f")
end

results << BM.bm("converting back and forth") do |bm|
  bm.time("NArr.to_a")
  bm.time("NArray.to_na(Arr)")
  bm.time("NArray[*Arr]")
end

results << BM.bm("iteration") do |bm|
  %w(Arr NArr).each do |ar|
    bm.time("#{ar}.each {|v| v }")
  end
end

results << BM.bm("indexing") do |bm|
  %w(Arr NArr).each do |ar|
    bm.time("(0...Len).each {|i| #{ar}[i] }")
  end
end


puts results.map {|v| v.to_pairs}.to_yaml





#@ar = (0...length).to_a.map {|v| v.to_f }
#@fl = NArray.to_na(@ar)
#@sfl = NArray.sfloat(@ar.size)
#@sfl[true] = @fl[true]

#puts "Iteration with #each is slightly faster with Array"

#labels = ['array', 'NArray.float', 'NArray.sfloat']
#bm.report(labels[0]) { @ar.each {|v| v * v } }
#bm.report(labels[1]) { @fl.each {|v| v * v } }
#bm.report(labels[2]) { @sfl.each {|v| v * v } }
#end

#labels.zip(reply) do |label, tms|
#p label
#puts "#{length.to_f / tms.utime}" + "element Hz" 
#end


#p reply 
#abort 'her'


##Benchmark.bmbm do |bm|
##bm.report('array') { @ar.each {|v| v } }
##bm.report('NArray.float') { @fl.each {|v| v } }
##bm.report('NArray.sfloat') { @sfl.each {|v| v } }
##end

##puts '~100X faster to NArray#sum'

##Benchmark.bmbm do |bm|
##bm.report('array#inject(0.0, :+)') { @ar.inject(0.0, :+) }
##bm.report('array#inject(0.0) {|sum, v| sum+v }') { @ar.inject(0.0) {|sum, v| sum+v } }
##bm.report('array#each {|v| sum += v }') { sum = 0.0 ; @ar.each {|v| sum += v } }
##bm.report('NArray.float') { sum = @fl.sum }
##bm.report('NArray.sfloat') { sum = @sfl.sum }
##end






