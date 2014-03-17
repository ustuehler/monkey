# Load all data models and call DataMapper.finalize.

require 'monkey/business/customer'
require 'monkey/business/invoice'
require 'monkey/business/supplier'

# XXX: DataMapper requires a default repository
unless DataMapper::Repository.adapters.has_key?(:default)
  DataMapper.setup :default, 'sqlite::memory:'
end

DataMapper.finalize
