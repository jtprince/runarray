
module Runarray
  class NArray < Array

    #alias_method :old_select, :select

    undef_method :each_with_index
    undef_method :map
    undef_method :select

    class << self
    end
  end
end

=begin

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
=end

 
