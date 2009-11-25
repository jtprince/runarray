
shared 'an narray' do

  before do
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

shared 'initializing a 1D NArray' do
  it 'with new' do
    fna = @klass.new('float', 3)
    fna.size.is 3
    fna.shape.is [3]
    fna.enums [@zero, @zero, @zero]
  end
end

shared "an empty 1D NArray" do

  before do
    #@klass
    #@typedef
    #@zero
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
    # @array  # <- define this
    @narr = @klass.to_na(@array)
  end

  it 'can be indexed into in traditional ways' do
    [0, 3, -1, -2].each do |v|
      @narr[v].should.equal @array[v]
    end
  end

  it 'can be indexed into in narray idiosyncratic ways' do
    @narr[true].enums @array
    @narr[3..2].enums @array[2..3].reverse
    @narr[].enums @narr
    @narr[[2,0]].enums [@array[2], @array[0]]
    @narr[[0]].enums [@array[0]]
  end

end
