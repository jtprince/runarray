require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/narray_shared')

require 'narray'

%w(float int).each do |typedef|
  describe "an NArray #{typedef}" do
    before do
      @klass = NArray
      @typedef = typedef
    end
    behaves_like 'an narray'
  end
end
