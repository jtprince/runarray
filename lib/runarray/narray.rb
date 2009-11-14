
module Runarray
  class NArray < Array

    alias_method :old_map, :map
    alias_method :old_select, :select

    class << self

      def float(*dims)
        build('float', *dims)
      end

      def int(*dims)
        build('int', *dims)
      end

      def to_na(arr)
        new(arr)
      end

      def [](*args)
        new(args)
      end

      def build(typecode, *dims)
        zero = 
          case typecode
          when 'float' : 0.0
          when 'int' : 0
          end
        raise NotImplementedError, "dims <= 1 right now" if dims.size > 2
        case dims.size
        when  1
          self.new(dims.first, zero)
        end
      end

    end

    def self.max(first, second)
      if first >= second ; first
      else ; second
      end
    end

    def self.min(first, second)
      if first <= second ; first
      else ; second
      end
    end

    alias_method :dim, :size
    alias_method :old_map, :map
    alias_method :old_select, :select
    @@zero = 0.0

    TYPECODES = ['float', 'int']


    def initialize(*args)
      if TYPECODES.include?(args[0])
        self.class.build(*args)
      else
        super(*args)
      end
    end

    ## BASIC METHODS:

    def log_space(&block)
      logged = self.map{|v| Math.log(v) }
      new_ar = block.call(logged)
      self.class.new( new_ar.map{|v| Math.exp(v) } )
    end

    def inspect
      "[ #{self.join(", ")} ]" 
    end

    def select(&block)
      self.class.new(old_select(&block))
    end

    def map(&block)
      self.class.new(old_map(&block))
    end

    def to_s
      self.join(" ")
    end

    #def dup
    #  self.class.new(self)
    #end

    #def ==(other)
    #  if other == nil
    #    return false
    #  end
    #  self.each_index do |i|
    #    if self[i] != other[i]
    #      return false
    #    end
    #  end
    #  true
    #end

    def to_a
      x = []
      self.each do |it|
        x << it
      end
      x
    end

    method_alias :slice, :old_slice

    def slice(*args)
      if args.first == true
        self.dup
       #elsif
#####################################################
#####################################################
#####################################################
        # HERRER!
#####################################################
#####################################################
#####################################################
#####################################################
#####################################################
      # TODO: WORKING HERE!!
      end
    end

    # for each value in mat, take a certain fraction and make it random
    # random fraction can be from 0 to 2X the original fraction.
    def noisify!(fraction, precision=1000000)
      self.collect! do |val| 
        part = fraction * val
        rnum = rand((2*part*precision).to_i)
        random = rnum.to_f/precision
        answ = val - part
        if val > 0
          answ + random
        else
          answ - random
        end
      end
    end

    def histogram(*arg)
      require 'histogram'
    end

    # Takes input and converts to whatever internal representation
    # SUBCLASS THIS GUY!
    def to_rep(val)
      val.to_f
    end

    # Accepts an Array, Vector, or list
    # Returns a new Object
    # Basically just does a to_rep on each element
    def self.prep(input)
      obj = self.new
      (0...input.size).each do |i|
        obj[i] = obj.to_rep(input[i])
      end
      obj
    end

    ########################################
    # BREAD AND BUTTER
    ########################################

    # the operator
    #def operator(sym, other)
    #  nw = self.class.new
    #  if other.kind_of?(Vec)
    #    self.each_with_index do |val,i|
    #      nw << val.send(sym, other[i])
    #    end
    #  else
    #    self.each do |val|
    #      nw << val.send(sym, other)
    #    end 
    #  end
    #  nw
    #end

    #def /(other); send('/'.to_sym, other) end
    #def +(other); send('+'.to_sym, other) end
    #def -(other); send('-'.to_sym, other) end
    #def *(other); send('*'.to_sym, other) end

    def /(other)
      nw = self.class.new
      if other.kind_of?(Runarray::NArray)
        self.each_with_index do |val,i|
          nw << val / other[i]
        end
      else
        self.each do |val|
          nw << val / other
        end 
      end
      nw
    end

    def **(other)
      nw = self.class.new
      if other.kind_of?(Runarray::NArray)
        self.each_with_index do |val,i|
          nw << (val ** other[i])
        end
      else
        self.each do |val|
          nw << val ** other
        end 
      end
      nw
    end

    def *(other)
      nw = self.class.new
      if other.kind_of?(Runarray::NArray)
        self.each_with_index do |val,i|
          nw << val * other[i]
        end
      else
        self.each do |val|
          nw << val * other
        end 
      end
      nw
    end

    def +(other)
      nw = self.class.new
      if other.kind_of?(Runarray::NArray)
        self.each_with_index do |val,i|
          nw << val + other[i]
        end
      else
        self.each do |val|
          nw << val + other
        end 
      end
      nw
    end

    def -(other)
      nw = self.class.new
      if other.kind_of?(Runarray::NArray)
        self.each_with_index do |val,i|
          nw << val - other[i]
        end
      else
        self.each do |val|
          nw << val - other
        end 
      end
      nw
    end

    def abs
      nw = self.class.new
      self.each do |val|
        nw << val.abs
      end
      nw
    end

    def floor
      nw = self.class.new
      self.each do |val|
        nw << val.floor
      end
      nw
    end

    def sum
      sum = @@zero
      self.each do |val|
        sum += val 
      end
      sum
    end

    # returns a float
    def avg
      sum.to_f/self.size
    end

    ########################################
    # MORE INVOLVED
    ########################################

    # returns (new_x_coords, new_y_coords) of the same type as self
    # Where:
    #   self = the current x coordinates
    #   yvec = the parallel y coords 
    #   start = the initial x point
    #   endp = the final point
    #   increment = the x coordinate increment
    #   baseline = the default value if no values lie in a bin
    #   behavior = response when multiple values fall to the same bin
    #     sum => sums all values
    #     avg => avgs the values
    #     high => takes the value at the highest x coordinate
    #     max => takes the value of the highest y value [need to finalize]
    #     maxb => ?? [need to finalize]
    def inc_x(yvec, start=0, endp=2047, increment=1.0, baseline=0.0, behavior="sum")
      xvec = self


      scale_factor = 1.0/increment
      end_scaled = ((endp * (scale_factor)) + 0.5).to_int 
      start_scaled = ((start* (scale_factor)) + 0.5).to_int 


      # the size of the yvec will be: [start_scaled..end_scaled] = end_scaled - start_scaled + 1
      ## the x values of the incremented vector: 
      xvec_new_size = (end_scaled - start_scaled + 1)
      xvec_new = self.class.new(xvec_new_size)
      # We can't just use the start and endp that are given, because we might
      # have needed to do some rounding on them
      end_unscaled = end_scaled / scale_factor
      start_unscaled = start_scaled / scale_factor
      xval_new = start_unscaled
      xvec_new_size.times do |i|
        xvec_new[i] = start_unscaled
        start_unscaled += increment
      end

      # special case: no data
      if xvec.size == 0
        yvec_new = self.class.new(xvec_new.size, baseline)
        return [xvec_new, yvec_new]
      end

      ## SCALE the mz_scaled vector
      xvec_scaled = xvec.collect do |val|
        (val * scale_factor).round
      end

      ## FIND greatest index
      _max = xvec_scaled.last

      ## DETERMINE maximum value
      max_ind = end_scaled
      if _max > end_scaled; max_ind = _max ## this is because we'll need the room
      else; max_ind = end_scaled
      end

      ## CREATE array to hold mapped values and write in the baseline
      arr = self.class.new(max_ind+1, baseline)
      nobl = self.class.new(max_ind+1, 0)

      case behavior
      when "sum"
        xvec_scaled.each_with_index do |ind,i|
        val = yvec[i]
        arr[ind] = nobl[ind] + val
        nobl[ind] += val
        end
      when "high"  ## FASTEST BEHAVIOR
        xvec_scaled.each_with_index do |ind,i|
          arr[ind] = yvec[i]
        end
      when "avg"
        count = Hash.new {|s,key| s[key] = 0 }
        xvec_scaled.each_with_index do |ind,i|
          val = yvec[i]
          arr[ind] = nobl[ind] + val
          nobl[ind] += val
          count[ind] += 1
        end
        count.each do |k,co|
          if co > 1;  arr[k] /= co end
        end
      when "max" # @TODO: finalize behavior of max and maxb
        xvec_scaled.each_with_index do |ind,i|
          val = yvec[i]
          if val > nobl[ind];  arr[ind] = val; nobl[ind] = val end
        end
      when "maxb"
        xvec_scaled.each_with_index do |ind,i|
        val = yvec[i]
        if val > arr[ind];  arr[ind] = val end
        end
      else 
        warn "Not a valid behavior: #{behavior}, in one_dim\n"
      end

      trimmed = arr[start_scaled..end_scaled]
      if xvec_new.size != trimmed.size
        abort "xvec_new.size(#{xvec_new.size}) != trimmed.size(#{trimmed.size})"
      end
      [xvec_new, trimmed]
    end

    def pearsons_r(y)
      x = self
      sum_xy = @@zero
      sum_x = @@zero
      sum_y = @@zero
      sum_x2 = @@zero
      sum_y2 = @@zero
      n = x.size

      x.each_with_index do |xval,i|
        yval = y[i]
        sum_xy += xval * yval
        sum_x += xval
        sum_y += yval
        sum_x2 += xval**2
        sum_y2 += yval**2 
      end

      ## Here it is:
      # 'E' is Capital Sigma 
      # r = EXY - (EXEY/N) 
      #    -----------------
      #    sqrt( (EX^2 - (EX)^2/N) * (EY^2 - (EY)^2/N) )

      top = sum_xy.to_f - ((sum_x * sum_y).to_f/n)
      fbot = sum_x2.to_f - ((sum_x**2).to_f/n)
      sbot = sum_y2.to_f - ((sum_y**2).to_f/n)
      top / Math.sqrt(fbot * sbot)
    end

    # Returns (rsq, slope, y_intercept)
    def rsq_slope_intercept(y)
      x = self
      if y.size != x.size then raise ArgumentError, "y must have same size as self!" end
      if x.size < 2
        raise ArgumentError, "vectors must have 2 or more data points!"
      elsif x.size == 2
        l = x[1]; fl = y[1]; s = x[0]; fs = y[0]
        if x[0] > x[1] ; l,s=s,l; fl,fs=fs,fl end
        if l-s == 0 then raise ArgumentError, "two points same x" end
        slope = (fl-fs)/(l-s)
        # y = mx + b
        # b = y - mx
        y_intercept = fl - (slope*l)
        rsq = 1.0   
        return rsq, slope, y_intercept
      else
        x = self
        mean_x = x.avg
        mean_y = y.avg
        sum_sq_res_xx = @@zero
        sum_sq_res_yy = @@zero
        sum_sq_res_xy = @@zero
        x.each_with_index do |val,i|
          x_minus_mean_i = x[i].to_f - mean_x
          y_minus_mean_i = y[i].to_f - mean_y
          sum_sq_res_xx += x_minus_mean_i*x_minus_mean_i
          sum_sq_res_yy += y_minus_mean_i*y_minus_mean_i
          sum_sq_res_xy += x_minus_mean_i*y_minus_mean_i
        end
        slope = sum_sq_res_xy/sum_sq_res_xx
        y_intercept = mean_y - (slope * mean_x) 
        rsq = (sum_sq_res_xy*sum_sq_res_xy)/(sum_sq_res_xx*sum_sq_res_yy)
        return rsq, slope, y_intercept
      end
    end

    # Returns (mean, standard_dev)
    # if size == 0 returns [nil, nil]
    def sample_stats
      _len = size
      return [nil, nil] if _len == 0
      _sum = 0.0
      _sum_sq = 0.0
      self.each do |val|
        _sum += val
        _sum_sq += val * val
      end
      std_dev = _sum_sq - ((_sum * _sum)/_len)
      std_dev /= ( _len > 1 ? _len-1 : 1 )
      std_dev = Math.sqrt(std_dev)
      mean = _sum.to_f/_len
      return mean, std_dev
    end

    # moving average (slow, simple implementation)
    def moving_avg(pre=1, post=1)
      last_index = self.size - 1
      ma = self.class.new(self.size)
      self.each_with_index do |center,index|
        start_i = index - pre
        start_i >= 0 or start_i = 0
        end_i = index + post
        end_i < self.size or end_i = last_index
        ma[index] = self[start_i..end_i].avg
      end
      ma
    end

=begin
  # in progress on this guy: moving average
  def moving_avg(pre=1, post=1)
    ar_size = size
    mv_avg = self.class.new(size)
    window_size = pre + post + 1
    window_size_f = window_size.to_f
    sum = 0.0

    # do the first bit 
    if post + 1 > ar_size
      post = ar_size
    end

    post_p1 = post+1
    (0...(post_p1)).each do |i|
      sum += self[i]
    end
    self[0] = sum / (post_p1)

    ((post+1)...window_size).each do |add_i|
      sum += self[add_i]
      self[add_i - (post_p1)] = sum / 
    end

    # the middle bit
    (window_size...(size - window_size)).each do |i|
      sum -= self[i - pre]
      sum += self[i + post]
      mv_avg[i] = sum / window_size_f
    end

    # do the last bit
    ((size - window_size)...size).each do |i|
      window_size -= 1
      mv_avg[i] = sum / window_size
    end

    mv_avg
  end

=end

    # Returns (x, y) where any data points 
    # in cartesion coords(self,y) that are > 'deviations' from the 
    # least squares regression line are deleted.
    # The least squares line is recalculated and outliers tossed out
    # iteratively until no further points are tossed.
    # In the future this may be for multiple vecs...
    def delete_outliers_iteratively(deviations, y=nil)
      x = self
      ln = x.size
      nx = nil
      ny = nil
      loop do
        answ = x.delete_outliers(deviations, y)
        if y
          (nx, ny) = answ
        else
          nx = answ
        end
        if nx.size == ln
          break
        else
          ln = nx.size
          x = nx
          y = ny ## still nil if only x
        end
      end
      if y
        [nx, ny]
      else
        nx
      end
    end

    def outliers_iteratively(deviations, y=nil)
      xdup = self.dup
      ydup = y.dup if y
      indices = nil
      all_indices = []
      loop do
        indices = xdup.outliers(deviations, ydup)
        all_indices << indices.dup
        if indices.size == 0
          break
        else
          indices.reverse.each do |i|
            xdup.delete_at(i)
            ydup.delete_at(i) if y
          end
        end
      end
      _correct_indices(all_indices)
    end

    # given indices that were deleted in sequential order, reconstruct
    # the original indices
    # e.g. ( '*' indicates that the index was deleted in that round )
    #   [ 0][  ][ 2][ 3][  ][*5][ 6][  ][ 8]
    #     |       |   |         /        / 
    #   [*0][  ][ 2][*3][  ][ 5][  ][ 7][  ]
    #           /      _____/  _____/            
    #   [  ][ 1][  ][*3][  ][ 5][  ][  ][  ]
    #         |             /
    #   [  ][*1][  ][  ][*4][  ][  ][  ][  ]
    #   ### -> ANSWER: [0,2,3,5,6,8]
    def _correct_indices(indices)
      ## need to correct the indices based on what was deleted before
      indices_new = indices.reverse.inject do |final,ind_ar|
        new_final = final.collect do |fi|
          rtn = fi
          ind_ar.each do |ind|
            if ind <= fi
              rtn += 1 
            end
          end
          rtn
        end
        new_final.push(*ind_ar)
        new_final
      end
      indices_new.sort
    end

    # returns an ary of indices to outliers
    # if y is given, the residuals from the least squares between self and y are
    # calculated before finding outliers
    def outliers(deviations, y=nil)
      indices = []
      distribution = 
        if y 
          self.residuals_from_least_squares(y)
        else
          self
        end
      mean, std_dev = distribution.sample_stats
      cutoff = deviations.to_f * std_dev
      distribution.each_with_index do |res,i|
        if (res - mean).abs > cutoff
          indices << i 
        end
      end
      indices
    end

    # Returns (x, y) where any data points 
    # in cartesion coords(self,y) that are > 'deviations' from the 
    # least squares regression line are deleted
    # (deviations will be converted to float)
    # In the future this may be for multiple vecs...
    def delete_outliers(deviations, y=nil)
      nx = self.class.new
      ny = self.class.new if y
      distribution = 
        if y
          self.residuals_from_least_squares(y)
        else
          self
        end
      mean, std_dev = distribution.sample_stats
      cutoff = deviations.to_f * std_dev
      #puts "CUTOFF: #{cutoff}"
      distribution.each_with_index do |res,i|
        #puts "RES: #{res}"
        unless (res - mean).abs > cutoff
          #puts "ADDING"
          nx << self[i] 
          (ny << y[i]) if y
        end
      end
      if y
        [nx,ny]
      else
        #puts "GIVING BACK"
        nx
      end
    end

    # Returns a NArray object (of doubles)
    def residuals_from_least_squares(y)
      rsq, slope, intercept = rsq_slope_intercept(y)
      residuals = Runarray::NArray.float
      self.each_with_index do |val,i|
        expected_y = (slope*val) + intercept 
        ydiff = y[i].to_f - expected_y
        if ydiff == 0.0
          residuals << 0.0
        else
          run = ydiff/slope
          residuals << run/( Math.sin(Math.atan(ydiff/run)) )
        end
      end
      residuals
    end

    def min
      mn = self.first
      self.each do |val|
        if val < mn then mn = val end
      end
      mn
    end

    def max
      mx = self.first
      self.each do |val|
        if val > mx ; mx = val end
      end
      mx
    end

    def shuffle!
      ##################################
      ## this is actually slightly faster, but I don't know how stable
      #size.downto(1) { |n| push delete_at(rand(n)) }
      #self
      ##################################
      (size - 1) .downto 1 do |i|
        j = rand(i + 1)
        self[i], self[j] = self[j], self[i]
      end
      self
    end

    def shuffle
      self.dup.shuffle!
    end

    # returns an array of indices
    def max_indices
      indices_equal(self.max)
    end

    # returns the indices as VecI object which indicate the ascending order of
    # the values tie goes to the value closest to the front of the list
    def order
      sorted = self.sort
      hash = Hash.new {|h,k| h[k] = [] }
      self.each_with_index do |sortd,i|
        hash[sortd] << i
      end
      ord = sorted.map do |val|
        hash[val].shift
      end
      Runarray::NArray.new('int').replace(ord)
    end

    # returns an Array of indices where val == member
    def indices_equal(val)
      indices = []
      self.each_with_index do |v,i|
        if val == v
          indices << i
        end
      end
      indices
    end

    # returns an array of indices
    def min_indices
      indices_equal(self.min)
    end


    # these are given in inclusive terms output is the array used for placing
    # the data in (expects same size).  If nil it will be in-place.
    def clip(min, max, output=nil)
      output ||= self
      self.each_with_index do |v,i|
        n = v
        n = min if v < min 
        n = max if v > max
        output[i] = n
      end
      output
    end

    # Returns (min, max)
    def min_max
      mn = self.first
      mx = self.first
      self.each do |val|
        if val < mn then mn = val end
        if val > mx then mx = val end
      end
      return mn, mx
    end

    # originally taken from a pastebin posting (2009-08-26) which is
    # considered public domain. (http://en.pastebin.ca/1255734)
    # self is considered the x values.  Returns y values at the x values given
    def lowess(y, f=2.0/3.0, iter=3) 
      x = self
      n = x.size
      r = (f*n).ceil.to_i
      # h = [numpy.sort(numpy.abs(x-x[i]))[r] for i in range(n)]
      (0...n).each { |i| (x-x[i]).abs.sort[r] }
      raise NotImplementedError, "not finished!"
       
      #w = numpy.clip(numpy.abs(([x]-numpy.transpose([x]))/h),0.0,1.0)
      #w = 1-w*w*w
      #w = w*w*w
      #yest = numpy.zeros(n)
      #delta = numpy.ones(n)
      #for iteration in range(iter):
      #  for i in range(n):
      #    weights = delta * w[:,i]
      #  theta = weights*x
      #  b_top = sum(weights*y)
      #  b_bot = sum(theta*y)
      #  a = sum(weights)
      #  b = sum(theta)
      #  d = sum(theta*x)
      #  yest[i] = (d*b_top-b*b_bot+(a*b_bot-b*b_top)*x[i])/(a*d-b**2)
      #  residuals = y-yest
      #  s = numpy.median(abs(residuals))
      #  delta = numpy.clip(residuals/(6*s),-1,1)
      #  delta = 1-delta*delta
      #  delta = delta*delta
      #  return yest

    end


#"""
#This module implements the Lowess function for nonparametric regression.

#Functions:
#lowess        Fit a smooth nonparametric regression curve to a scatterplot.

#For more information, see

#William S. Cleveland: "Robust locally weighted regression and smoothing
#scatterplots", Journal of the American Statistical Association, December 1979,
#volume 74, number 368, pp. 829-836.

#William S. Cleveland and Susan J. Devlin: "Locally weighted regression: An
#approach to regression analysis by local fitting", Journal of the American
#Statistical Association, September 1988, volume 83, number 403, pp. 596-610.
#"""

#import numpy
#try:
    #from Bio.Cluster import median
    ## The function median in Bio.Cluster is faster than the function median
    ## in NumPy, as it does not require a full sort.
#except ImportError, x:
    ## Use the median function in NumPy if Bio.Cluster is not available
    #from numpy import median

#def lowess(x, y, f=2./3., iter=3):
    #"""lowess(x, y, f=2./3., iter=3) -> yest

#Lowess smoother: Robust locally weighted regression.
#The lowess function fits a nonparametric regression curve to a scatterplot.
#The arrays x and y contain an equal number of elements; each pair
#(x[i], y[i]) defines a data point in the scatterplot. The function returns
#the estimated (smooth) values of y.

#The smoothing span is given by f. A larger value for f will result in a
#smoother curve. The number of robustifying iterations is given by iter. The
#function will run faster with a smaller number of iterations."""
    #n = len(x)
    #r = int(numpy.ceil(f*n))
    #h = [numpy.sort(numpy.abs(x-x[i]))[r] for i in range(n)]
    #w = numpy.clip(numpy.abs(([x]-numpy.transpose([x]))/h),0.0,1.0)
    #w = 1-w*w*w
    #w = w*w*w
    #yest = numpy.zeros(n)
    #delta = numpy.ones(n)
    #for iteration in range(iter):
        #for i in range(n):
            #weights = delta * w[:,i]
            #theta = weights*x
            #b_top = sum(weights*y)
            #b_bot = sum(theta*y)
            #a = sum(weights)
            #b = sum(theta)
            #d = sum(theta*x)
            #yest[i] = (d*b_top-b*b_bot+(a*b_bot-b*b_top)*x[i])/(a*d-b**2)
        #residuals = y-yest
        #s = numpy.median(abs(residuals))
        #delta = numpy.clip(residuals/(6*s),-1,1)
        #delta = 1-delta*delta
        #delta = delta*delta
    #return yest

    alias_method :loess, :lowess

=begin
  # complete rewrite of the 
  # returns empty derivs for size == 0
  # returns 0 for size == 1
  # does linear interpolation for size == 2
  # does three point derivative for everything else
  # zero_for_inflection is the "adjusted to be shape-preserving" spoken of in
  # the SLATEC chim code.
  def derivs(y, zero_for_inflection=true)
    dvs = self.class.new(size)
    x = self
    case size
    when 0
      dvs
    when 1
      dvs[0] = 0
      dvs
    when 2
      slope = (y[1] - y[0])/(x[1] - x[0])
      dvs[0], dvs[1] = slope, slope
    else  
      dvs[0] = (y[1] - y[0])/(x[1] - x[0])
      cnt = 1
      x.zip(y).each_cons(3) do |pre,cur,post|
        pre_x, pre_y = pre
        post_x, post_y = post
        cur_x, cur_y = cur
        dvs[cnt] =
          if zero_for_inflection
            r_post_slope = post_y <=> cur_y
            r_pre_slope = pre_y <=> cur_y
            if r_post_slope != 0 and r_pre_slope != 0 and (r_post_slope * -1) == r_pre_slope
              0
            else
              three_point_deriv(pre, cur, post)
            end
          else
            three_point_deriv(pre, cur, post)
          end
        cnt += 1
      end
      dvs
    end
  end
=end

    # difference between max and min
    def spread
      (max - min).abs
    end

    def nil?
      false
    end

    # Class functions:
    # THIS MUST BE FOR FLOAT AND DOUBLE ONLY!!!
    # This is a fairly precise Fortran->C translation of the SLATEC chim code
    # Evaluate the deriv at each x point
    # return 1 if less than 2 data points
    # return 0 if no errors
    # ASSUMES monotonicity of the X data points !!!!!
    # ASSUMES that this->length() >= 2
    # If length == 1 then derivs[0] is set to 0
    # If length == 0 then raises an ArgumentError
    # returns a new array of derivatives
    # Assumes that y values are Floats
    # if y is not given, then values are assumed to be evenly spaced.
    def chim(y=nil)
      y = self.class.new((0...(self.size)).to_a) if y.nil?

      #void VecABR::chim(VecABR &x, VecABR &y, VecABR &out_derivs) {
      x = self
      derivs = Runarray::NArray.new(x.size)

      length = x.size
      three = 3.0

      ierr = 0
      lengthLess1 = length - 1

      if length < 2 
        if length == 1
          derivs[0] = 0
          return derivs
        else 
          raise ArgumentError, "trying to chim with 0 data points!"
        end
      end

      h1 = x[1] - x[0]
      slope1 = (y[1] - y[0]) / h1
      slope_save = slope1

      # special case length=2 --use linear interpolation
      if lengthLess1 < 2
        derivs[0] = slope1
        derivs[1] = slope1
        return derivs
      end 

      # Normal case (length >= 3)

      h2 = x[2] - x[1]
      slope2 = (y[2] - y[1]) / h2

      # SET D(1) VIA NON-CENTERED THREE-POINT FORMULA, ADJUSTED TO BE
      #     SHAPE-PRESERVING.

      hsum = h1 + h2
      w1 = (h1 + hsum)/hsum
      w2 = (h1*-1.0)/hsum
      derivs[0] = (w1*slope1) + (w2*slope2)
      if (( pchst(derivs[0], slope1) ) <= 0)
        derivs[0] = @@zero
      elsif ( pchst(slope1, slope2) < 0 )
        # need to do this check only if monotonicity switches
        dmax = slope1 * three
        if (derivs[0].abs > dmax.abs) 
          derivs[0] = dmax
        end 
      end

      (1...lengthLess1).to_a.each do |ind|
        if (ind != 1)
          h1 = h2
          h2 = x[ind+1] - x[ind]
          hsum = h1 + h2
          slope1 = slope2
          slope2 = (y[ind+1] - y[ind])/h2
        end 

        derivs[ind] = @@zero

        pchstval = pchst(slope1, slope2)

        klass = self.class

        if (pchstval > 0) 
          hsumt3 = hsum+hsum+hsum
          w1 = (hsum + h1)/hsumt3
          w2 = (hsum + h2)/hsumt3
          dmax = klass.max( slope1.abs, slope2.abs )
          dmin = klass.min( slope1.abs, slope2.abs )
          drat1 = slope1/dmax
          drat2 = slope2/dmax
          derivs[ind] = dmin/(w1*drat1 + w2*drat2)
        elsif (pchstval < 0 )
          ierr = ierr + 1
          slope_save = slope2
          next
        else   # equal to zero
          if (slope2 == @@zero) 
            next
          end
          if (pchst(slope_save,slope2) < 0) 
            ierr = ierr + 1 
          end
          slope_save = slope2
          next
        end 
      end


      w1 = (h2*-1.0)/hsum
      w2 = (h2 + hsum)/hsum
      derivs[lengthLess1] = (w1*slope1) + (w2*slope2)
      if ( pchst(derivs[lengthLess1], slope2) <= 0 ) 
        derivs[lengthLess1] = @@zero;
      elsif ( pchst(slope1, slope2) < 0)
        # NEED DO THIS CHECK ONLY IF MONOTONICITY SWITCHES.
        dmax = three*slope2
        if (derivs[lengthLess1].abs > dmax.abs) 
          derivs[lengthLess1] = dmax
        end 
      end 
      derivs
    end


    # called as (points, &block)
    # or (pre, post, &block)
    # points e.g. 3, means one before, current, and one after)
    # pre = 1 and post = 1 is 3 points
    # pre = 2 and post = 2 is 5 points
    # yields a Vec object with the objects to be acted on and sets the value to
    # the return value of the block.
    def transform(*args, &block)
      (pre, post) = 
        if args.size == 1
          pre = (args[0] - 1) / 2
          post = pre
          [pre, post]
        elsif args.size == 2
          args
        else 
          raise(ArgumentError, "accepts (pre, post, &block), or (points, &block)")
        end
      trans = self.class.new(size)
      last_i = self.size - 1
      # TODO: could implement with rolling yielded array and be much faster...
      self.each_with_index do |x,i|
        start = i - pre
        stop = i + post
        start = 0 if start < 0
        stop = last_i if stop > last_i
        trans[i] = block.call(self[start..stop])
      end
      trans
    end


    private

    def pchst(arg1, arg2)
      if arg1*arg2 > 0
        1
      elsif arg1*arg2 < 0 
        -1
      else
        0
      end
    end

    # returns float
    def avg_ints(one, two)
      (one.to_f + two.to_f)/2.0
    end
  end



  #class VecD < Vec
  #end

  #class VecI < Vec
    #tmp = $VERBOSE ; $VERBOSE = nil
    #@@zero = 0
    #$VERBOSE = tmp

    #def to_rep(val)
      #val.to_i
    #end
  #end


end
