require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/../runarray_shared")

require 'narray/runarray'

describe 'an narray runarray object' do
  @klass = NArray::Runarray
  behaves_like "a runarray object"
end
