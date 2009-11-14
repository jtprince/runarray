module ArrayEqual
  # equal shape, dimensions, members
  def array_equal(other)
    cnt = 0
    each do |x|
      x.should.equal other[cnt]
      cnt += 1
    end
  end

  def deep_array_equal(other)
    array_equal(other)
    self.object_id.should.not.equal other.object_id
  end
end

shared 'an narray' do

  before do
    @klass.module_eval "include ArrayEqual"
    case @typedef
    when 'float' 
      @zero = 0.0
      cast = :to_f
    when 'int'
      @zero = 0
      cast = :to_i
    else
      abort 'unrecognized @typedef'
    end
    @array = [1,2,3,4].map {|v| v.send(cast) }
  end

  # behaves_like 'an empty 1D NArray' 
  behaves_like 'a normal 1D NArray' 

end

shared "an empty 1D NArray" do
  before do
    @klass
    @typedef
    @zero
  end

  it 'has proper dimension and shape introspection' do
    x = @klass.new(@typedef, 30)
    x.size.should.equal 30
    x.dim.should.equal 1
    x.shape.should.equal [30]
    x.total.should.equal 30
  end

  it 'has all values at zero' do
    x = @klass.new(@typedef, 30)
    x.each {|v| v.should.equal @zero }
  end

  it 'can be initialized with typedef classmethod name' do
    val = @klass.send(@typedef.to_sym, 30)
    val.should.equal @klass.new(@typedef, 30)
  end

  it 'can be initialized with an array' do
    ar = [@zero, @zero, @zero]
    z = @klass.to_na ar
    ar.each_with_index do |v,i|
      z[i].should.equal v
    end
  end
end

shared 'a normal 1D NArray' do

  before do
    @array  # <- define this
    @narr = @klass.to_na(@array)
  end

  it 'can be indexed into in traditional ways' do
    [0, 3, -1, -2].each do |v|
      @narr[v].should.equal @array[v]
    end
  end

  it 'can be indexed into in narray idiosyncratic ways' do
    @narr[true].deep_array_equal @array
    @narr[3..2].deep_array_equal @array[2..3].reverse
    @narr[].deep_array_equal @narr
    @narr[[2,0]].deep_array_equal [@array[2], @array[0]]
    @narr[[0]].deep_array_equal [@array[0]]
  end

end
