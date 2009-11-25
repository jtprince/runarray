

shared 'a runarray object' do

  before do
    # @klass
    # @obj  # [1,2,3,4,5]
    @obj = @klass[1,2,3,4,5]
  end

  xit 'is instantiated like an NArray' do
  end

  it 'is enumerable' do
    ok @obj.size > 1
    cnt = 0

    @obj.each_with_index do |v, i|
      v.is @obj[i]
      cnt.is i
      cnt += 1
    end
    @obj.find {|v| v % 3 == 0 }.is 3
    @obj.find_all {|v| v > 3 }.enums [4,5]
    @obj.find_all {|v| v > 3 }.isa Array
    @obj.all? {|v| v > 0}.is true
    @obj.all? {|v| v == 3}.is false
    @obj.any? {|v| v == 2}.is true
    @obj.any? {|v| v == -1}.is false

    @obj.collect {|v| v + 5 }.isa Array
    @obj.map {|v| v + 5 }.isa Array

    @obj.zip(@obj) do |a,b|
      a.nil?.is false
      a.is b
    end
  end

end
