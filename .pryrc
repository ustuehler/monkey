require 'rubygems'

$:.unshift File.expand_path('../lib', __FILE__)

require 'monkey'

require 'monkey/business/resource'
require 'monkey/business/customer'
require 'monkey/business/invoice'

DataMapper.finalize

# XXX: DataMapper requires a default repository
DataMapper.setup :default, "yaml:#{File.expand_path '~/.monkey/resource'}"

# http://stackoverflow.com/questions/13617888/how-can-i-cd-to-a-class-object-in-a-pryrc-file
Pry.config.hooks.add_hook(:before_session, :set_context) do |a, b, pry|
  if self.class == Object and self.to_s == "main"
    pry.input = StringIO.new("cd Monkey")
  end
  Pry.config.hooks.delete_hook(:before_session, :set_context)
end
