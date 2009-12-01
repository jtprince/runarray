require 'benchmark'
require 'narray'
require 'orderedhash'

Len = 1000000
NArr = NArray[0...Len].to_f
Arr = (0...Len).to_a
DataD = NArr.to_a.pack("E*")
DataF = NArr.to_a.pack("e*")

class BM
  DEFAULT_NUM_REPEATS = 3
  attr_accessor :label

  # returns the BM object
  def self.bm(label, repeats=DEFAULT_NUM_REPEATS, &block)
    obj = new(label, repeats)
    block.call(obj)
    obj.bmbm
    obj
  end

  def initialize(label, repeats=DEFAULT_NUM_REPEATS)
    @repeats = repeats
    @label = label
    @to_measure = OrderedHash.new
    @measurements = OrderedHash.new

    @len = Len
    @narr = NArr
    @arr = Arr
    @dataD = DataD
    @dataF = DataF
  end
  
  def bmbm
    # fill in any ones without a block with the label
    @to_measure.each do |label, blk|
      if blk.nil?
        @to_measure[label] = lambda { eval label }
      end
    end
    # rehearsal
    @to_measure.each do |label, blk|
      Benchmark.measure &blk
    end
    @to_measure.each do |label, blk|
      @measurements[label] = Benchmark.measure{@repeats.times { blk.call } }.utime / @repeats
    end
  end

  def time(label, &block)
    @to_measure[label] = block
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
  bm.time("(0...@len).to_a")
  bm.time("(0...@len).to_a.map{|v| v.to_f}")
  bm.time("(0...@len).to_a")
  bm.time("NArray[0...@len].to_f")
  bm.time("NArray.float(@len).indgen!")
  bm.time("NArray.to_na((0...@len).to_a).to_f")
end


results << BM.bm("converting back and forth") do |bm|
  bm.time("NArr.to_a")
  bm.time("NArray.to_na(@arr)")
  bm.time("NArray[*@arr]")
end

results << BM.bm("iteration") do |bm|
  %w(@arr @narr).each do |ar|
    bm.time("#{ar}.each {|v| v }")
  end
end

results << BM.bm("indexing and setting") do |bm|
  %w(@arr @narr).each do |ar|
    bm.time("(0...@len).each {|i| #{ar}[i] }")
    bm.time("(0...@len).each {|i| #{ar}[i] = i}" )
  end
  bm.time("(0...@len).each {|i| @arr[i] = i}; NArray.to_na(@arr)" )
end

results << BM.bm("sum") do |bm|
  bm.time("@arr.inject(0.0, :+)")
  bm.time("@arr.inject(0.0) {|sum, v| sum+v }")
  bm.time("sum = 0.0 ; @arr.each {|v| sum += v }")
  bm.time("@narr.sum")
  bm.time("NArray.to_na(@arr).to_f.sum")
end

results << BM.bm("max") do |bm|
  bm.time("@arr.max")
  bm.time("@narr.max")
end

results << BM.bm("round") do |bm|
  bm.time("@arr.map {|v| v.round }")
  bm.time("@narr.round.to_i")
  bm.time("@arr.map {|v| v.round.to_f }")
  bm.time("@narr.round")
end

results << BM.bm("mean and standard deviation") do |bm|
  @len = Len
  @narr = NArr
  @arr = Arr
  @dataD = DataD
  @dataF = DataF

  bm.time("Array based with one pass through with :each") do
    _len = @arr.size
    _sum = 0.0
    _sum_sq = 0.0
    @arr.each do |val|
      _sum += val
      _sum_sq += val * val
    end
    std_dev = _sum_sq - ((_sum * _sum)/_len)
    std_dev /= ( _len > 1 ? _len-1 : 1 )
    std_dev = Math.sqrt(std_dev)
    mean = _sum.to_f/_len
  end
  bm.time("NArray by hand") do
    _len = @narr.size
    _sum = 0.0
    _sum_sq = 0.0
    _sum = @narr.sum
    _sum_sq = (@narr * @narr).sum
    std_dev = _sum_sq - ((_sum * _sum)/_len)
    std_dev /= ( _len > 1 ? _len-1 : 1 )
    std_dev = Math.sqrt(std_dev)
    mean = _sum.to_f/_len
  end
  bm.time("NArray, calling mean and stddev") do
    mean = @narr.mean
    std_dev = @narr.stddev
  end
end

results << BM.bm("unpacking from a string of floats", 10) do |bm|
  bm.time('@dataD.unpack("E*")')
  bm.time('@dataF.unpack("e*")')
  bm.time('NArray.to_na(@dataD, "float")')
  bm.time('NArray.to_na(@dataF, "sfloat")')
  bm.time('NArray.to_na(@dataF, "sfloat").to_f.to_a')
end

output = OrderedHash.new
results.each {|v| output[v.label] = v.to_pairs}

puts output.to_yaml

