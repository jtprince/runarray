module NArray::More

  # Returns (rsq, slope, y_intercept)
  def rsq_slope_intercept(y)
    x = self
    if y.size != x.size then raise ArgumentError, "y must have same size as self!" end
    if x.size < 2
      raise ArgumentError, "must have 2 or more data points!"
    elsif x.size == 2
      l = x[1]; fl = y[1]; s = x[0]; fs = y[0]
      if x[0] > x[1] ; l,s=s,l; fl,fs=fs,fl end
      raise ArgumentError, "two points same x" if l-s == 0
      slope = (fl-fs)/(l-s)
      # y = mx + b
      # b = y - mx
      y_intercept = fl - (slope*l)
      rsq = 1.0   
    else
      mean_x = x.mean
      mean_y = y.mean
      sum_sq_res_xx = @@zero
      sum_sq_res_yy = @@zero
      sum_sq_res_xy = @@zero
      (0...(x.size)).each do |i|
        x_minus_mean_i = x[i].to_f - mean_x
        y_minus_mean_i = y[i].to_f - mean_y
        sum_sq_res_xx += x_minus_mean_i*x_minus_mean_i
        sum_sq_res_yy += y_minus_mean_i*y_minus_mean_i
        sum_sq_res_xy += x_minus_mean_i*y_minus_mean_i
      end
      slope = sum_sq_res_xy/sum_sq_res_xx
      y_intercept = mean_y - (slope * mean_x) 
      rsq = (sum_sq_res_xy*sum_sq_res_xy)/(sum_sq_res_xx*sum_sq_res_yy)
    end
    [rsq, slope, y_intercept]
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
end

