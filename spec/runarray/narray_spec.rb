require File.dirname(__FILE__) + '/../spec_helper'

require 'narray'
require 'runarray/narray'

shared 'initializes' do

  before do
    @klass = nil  # you define the class
  end

  it 'initializes with different types' do
    @klass.float(3).enums [0.0, 0.0, 0.0]
    @klass.object(3).enums [nil, nil, nil]
    #@klass.byte(3).enums [ ]
  end

end

shared do
  include Runarray

  def initialize(*args)
    super(*args)
    @klass = NArray
  end

  it 'can be created with no arguments' do
    @klass = NArray
    obj1 = @klass.new
    obj1.size.must_equal 0
    obj1.class.must_equal @klass
  end

  it 'can be created given a desired size' do
    size = 10
    obj2 = @klass.new(size)
    obj2.size.must_equal size
    obj2.class.must_equal @klass
  end

  it 'can be created given an array' do
    obj3 = @klass.new([1.0,2.0,3.0])
    obj3.size.must_equal 3
    obj3.class.must_equal @klass
  end

  it 'will cast with prep and []' do
    obj4 = @klass.new([0.0,2.0,5.0])
    obj5 = @klass.prep([0,2,5]) # should be converted into floats
    obj6 = @klass[0,2,5]        # should be converted into floats
    obj4.each_index do |i|
      obj5[i].class.must_equal obj4[i].class # "prep converts to floats"
      obj6[i].class.must_equal obj4[i].class # "Class[] -> prep"
    end
  end

  it 'will NOT cast values with new' do
    obj4 = @klass.new([0.0,2.0,5.0])
    obj5 = @klass.prep([0,2,5]) # should be converted into floats
    obj6 = @klass[0,2,5]        # should be converted into floats
    obj7 = @klass.new([0,2,5])
    obj5.must_equal obj4
    obj6.must_equal obj4
    obj4.each_index do |i|
      obj7[i].class.wont_equal obj4[i].class # "w/o prep class stays int"
    end
  end

  it 'will call itself equal to another object if all vals equal' do
    obj4 = @klass.new([0.0,2.0,5.0])
    obj4.must_equal [0.0,2.0,5.0] # "arrays and objs may be equal"
    obj4.must_equal [0,2,5] # even if the types arr different, but equal val"

    obj8 = @klass[0,2,5]
    obj9 = @klass.new(obj8)
    obj9.must_equal obj8 #  "new from #{@klass} object"
    obj9.class.must_equal obj8.class 
  end

  it 'can do division' do
    x = NArray[8,4,2]
    y = NArray[4,2,1]
    (x / 2).must_equal NArray[4,2,1]
    vec_by_vec = NArray[2,2,2]
    (x / y).must_equal vec_by_vec
    x /= y
    x.must_equal vec_by_vec
  end

  it 'can do addition' do
    x = NArray[8,4,2]
    y = NArray[4,2,1]
    vec_by_vec = NArray[12,6,3]
    (x + y).must_equal vec_by_vec
    (x + 2).must_equal NArray[10,6,4]
    x += y
    x.must_equal vec_by_vec
  end
  
  it 'can do multiplication' do
    x = NArray[8,4,2]
    y = NArray[4,2,1]
    vec_by_vec = NArray[32,8,2]
    (x * y).must_equal vec_by_vec
    (x * 2).must_equal NArray[16,8,4]
    x *= y
    x.must_equal vec_by_vec
  end

  it 'can do subtraction' do
    x = NArray[8,4,2]
    y = NArray[4,2,1]
    vec_by_vec = NArray[4,2,1]
    (x - y).must_equal vec_by_vec
    (x - 2).must_equal NArray[6,2,0]
    x -= y
    x.must_equal vec_by_vec
  end

  it 'can calculate orders' do
    x = NArray[0.05, 0.5, 0.0009, 0.05, 0.5]
    x.order.must_equal [2,0,3,1,4]
  end

  def _inc_x(x,y,xexp, exp,mz_start,mz_end,inc,bl,type)
    (xvec, answ) = x.inc_x(y,mz_start,mz_end,inc,bl,type)
    xvec == xexp and answ.class == x.class and answ == exp
  end

  it 'works for _inc_x (private)' do

    bl = 33
    x = NArray.new([300, 301, 302, 304, 304, 304.2, 305, 306, 307.6])
    y = NArray.new([10, 20,  30,  50 , 55,  54,    70,  80,  90])
    xexp = (300..310).to_a
    exp = [10, 20, 30, bl, 159, 70, 80, bl, 90, bl, bl]
    _inc_x(x,y,xexp,exp,300,310,1,bl,"sum").must_equal true

    bl = 33
    x = NArray.new([300, 301, 302, 304, 304, 304.2, 305, 306, 307.6])
    y = NArray.new([10, 20,  30,  50 , 55,  54,    70,  80,  90])
    xexp = (300..310).to_a
    exp = [10, 20, 30, bl, 55, 70, 80, bl, 90, bl, bl]
    _inc_x(x,y,xexp,exp,300,310, 1, bl, "max" ).must_equal true

    bl = 15
    x = NArray.new([300, 301, 302, 304, 304, 304.2, 305, 306, 307.6])
    y = NArray.new([10, 20,  30,  50 , 55,  54,    70,  80,  90])
    xexp = (300..310).to_a
    exp = [bl, 20, 30, bl, 55, 70, 80, bl, 90, bl, bl]
    _inc_x(x,y,xexp,exp, 300, 310, 1, bl, "maxb" ).must_equal true

    bl = 33
    x = NArray.new([300, 301, 302, 304, 304, 304.2, 305, 306, 307.6])
    y = NArray.new([10, 20,  30,  50 , 55,  54,    70,  80,  90])
    xexp = (300..310).to_a
    exp = [10, 20, 30, bl, 54, 70, 80, bl, 90, bl, bl]
    _inc_x(x,y,xexp,exp, 300, 310, 1, bl, "high" ).must_equal true

    bl = 33
    x = NArray.new([300, 301, 302, 304, 304, 304.2, 305, 306, 307.6])
    y = NArray.new([10, 20,  30,  50 , 62,  68, 70,  80,  90])
    xexp = (300..310).to_a
    exp = [10, 20, 30, bl, 60, 70, 80, bl, 90, bl, bl]
    _inc_x(x,y,xexp,exp, 300, 310, 1, bl, "avg" ).must_equal true

  end

  it 'uses index notation' do
    obj1 = NArray.new(10)
    obj1[0].nil?.must_equal true
    obj1[0] = 1
    obj1[0].must_equal 1
  end

  it 'can calculate Pearsons R' do
    x = NArray.new([0,1,2,3,4,5,6,7,8,9,10])
    y = NArray.new([3,4,5,6,9,6,5,4,3,4,5])
    x.pearsons_r(y).must_be_close_to(-0.0709326902131908, 0.000000000001)
  end

  it 'can calculate rsq slope and intercept' do
    obj1 = NArray[0,2,5,5]
    obj2 = NArray[1,3,4,7]
    rsq, slope, inter = obj1.rsq_slope_intercept(obj2)
    rsq.must_be_close_to(0.758519, 0.000001)
    slope.must_be_close_to(0.888888888, 0.000001)
    inter.must_be_close_to(1.083333333, 0.000001)

    obj3 = NArray[1,3]
    obj4 = NArray[2,4]
    rsq, slope, inter = obj3.rsq_slope_intercept(obj4)
    [rsq, slope, inter].each {|v| v.must_equal 1.0 }
  end


  xit 'can find residuals from least squares' do
    obj1 = NArray[0,2,5,5]
    obj2 = NArray[1,3,4,7]
    out = obj1.residuals_from_least_squares(obj2)
    out.size.must_equal 4
    # frozen
    [-0.141112436470222, 0.235187394117037, -2.58706133528741, 2.49298637764059].zip(out) do |exp, ans|
      ans.must_be_close_to(exp, 0.0000000001)
    end
  end

  it 'can find sample stats (mean and stdev)' do
    obj1 = NArray[0,2,5,5,6,7]
    mean, std_dev = obj1.sample_stats
    mean.must_be_close_to(4.166666, 0.00001)
    std_dev.must_be_close_to(2.639444, 0.00001)
  end

  xit 'can find outliers by index' do
    NArray[0,1,1,2,1,2,10,1,0,0,1].outliers(2).must_equal [6]
    NArray[0,-10,1,2,1,2,10,1,0,0,1].outliers(2).must_equal [1,6]
  end

  xit 'can find outliers iteratively' do
    NArray[-1,-1,0,0,0,0,1,1,15,100].outliers(2).must_equal [9]
    NArray[-1,-1,0,0,0,0,1,1,15,100].outliers_iteratively(2).must_equal [8,9]
  end

  xit 'can delete outliers (for least squares residuals)' do
    # Consistency/sanity checks right now (not accuracy)
    x = NArray[-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,10,0 ,1,2,3,4,5,6,7,8,9]
    y = NArray[-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0 ,10,1,2,3,4,5,6,7,8,9]

    nx1, ny1 = x.delete_outliers(3.2, y) 
    expx1 = NArray[-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,10,1,2,3,4,5,6,7,8,9]
    expy1 = NArray[-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0 ,1,2,3,4,5,6,7,8,9]
    nx1.must_equal expx1
    ny1.must_equal expy1

    nx2, ny2 = x.delete_outliers(2.8, y) 
    expx2 = NArray[-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,1,2,3,4,5,6,7,8,9]
    expy2 = NArray[-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,1,2,3,4,5,6,7,8,9]
    nx2.must_equal expx2
    ny2.must_equal expy2

    #res = nx1.residuals_from_least_squares(ny1)
    #mean, std = res.sample_stats
    #puts res/std

    nx, ny = x.delete_outliers_iteratively(3.2, y) 
    nx.must_equal expx2
    ny.must_equal expy2
  end

  xit 'finds outliers (for least squares residuals)' do
    # Consistency/sanity checks right now (not accuracy)
    x = NArray[-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,10,0 ,1,2,3,7,5,6,7,8,9]
    y = NArray[-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0 ,10,1,2,3,4,5,6,7,8,9]
    xdup = x
    ydup = y

    ind = x.outliers(0.5, y) 
    ind.must_equal [10,11,15]

    ind = x.outliers(0.7, y) 
    ind.must_equal [10,11]

    ind2 = x.outliers_iteratively(0.7, y)
    ind2.must_equal [10,11,15]
    x.must_equal xdup # "method didn't change vector"
    y.must_equal ydup # "method didn't change vector"
  end
  
  it 'finds _correct_indices (private)' do
    NArray.new._correct_indices([[5],[0,3],[3],[1,4]]).must_equal [0,2,3,5,6,8]
  end

  # TODO: fix this spec
  # something is wrong in this guy
=begin
  it 'can noisify its values' do
    [[100,10,1],[-100,-10,-1]].each do |arr|
      x = NArray.prep(arr)
      xdup = x.dup
      fraction = 0.1

      10.times do 
        # this line is suspect:
        x = NArray.prep([0,2,3,5,6,8])
        x.noisify!(fraction)
        xdup.zip(x) do |arr|
          arr[1].must_be_close_to(arr[0], (fraction*arr[0]).abs)
        end
      end
    end
  end
=end
 
  it 'can duplicate itself' do
    x = NArray[100,10,1]
    d = x.dup
    d.must_equal x
    d.class.must_equal x.class
    x[0] = 10.0
    d.wont_equal x
  end

  it 'can do a moving average' do
    obj = NArray[0,1,2,3,4,5,6].moving_avg
    obj.must_equal [0.5, 1.0, 2.0, 3.0, 4.0, 5.0, 5.5]
    obj = NArray[0,1,2,3,10,5,6].moving_avg
    obj.must_equal [0.5, 1.0, 2.0, 5.0, 6.0, 7.0, 5.5]

    obj = NArray[0,1,2,3,4,5,6].moving_avg(4,4).must_equal [2.0, 2.5, 3.0, 3.0, 3.0, 3.5, 4.0]
    obj = NArray[0,1,2,3,4,5,6].moving_avg(0,6).must_equal [3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0]
    obj = NArray[0,1,2,3,4,5,6].moving_avg(6,0).must_equal [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0]
  end

  it 'can find 3-point derivatives (with chim)' do
    x = NArray[1]
    y = NArray[2]
    derivs = x.chim(y)
    derivs.must_equal [0]

    x = NArray[1,2]
    y = NArray[2,4]
    derivs = x.chim(y)
    derivs.must_equal [2.0, 2.0]

    x = NArray[0,1,2,3,4,5,6,7,8,9]
    y = NArray[0,10,12,4,5,2,7,9,10,4]
    derivs = x.chim(y)
    [14, 3.3333333, 0, 0, 0, 0, 2.8571429, 1.3333333, 0, -9.5].zip(derivs) do |exp, act|
      act.must_be_close_to(exp, 0.0001)
    end
 
  end

  it 'can do custom transformations (moving avg, stdev, etc)' do
    vec = NArray[0,1,2,3,3,4,2,1]
    # a three point moving average:
    answ = vec.transform(1, 1) {|x| x.avg }
    exp = [0.5, 1, 2, 8.0/3, 10.0/3, 3, 7.0/3, 3.0/2]
    answ.must_equal exp

    # 5 point stdeviation transformation
    pre = 2
    post = 2
    # transform with the standard deviation
    answ = vec.transform(pre, post) {|x| x.sample_stats[1] }
    exp = [1.0, 1.29099444873581, 1.30384048104053, 1.14017542509914, 0.836660026534075, 1.14017542509914, 1.29099444873581, 1.52752523165195]
    answ.zip(exp) do |ans, ex|
      ans.must_be_close_to(ex, 0.000000001)
    end
  end


end
