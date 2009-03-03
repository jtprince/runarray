
begin
  require 'narray'
rescue LoadError
  require 'runarray/narray'
  include Runarray
end

