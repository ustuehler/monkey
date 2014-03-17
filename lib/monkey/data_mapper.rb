require 'monkey'

# All code in monkey/data_mapper/**.rb may assume that DataMapper is loaded
# once they required 'monkey/data_mapper'.
require 'data_mapper'

module Monkey
  module DataMapper
    autoload :Resource, 'monkey/data_mapper/resource'
  end
end
