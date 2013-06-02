require 'data_mapper'

module Monkey::Business

  module Resource

    def self.included(klass)
      klass.send :include, DataMapper::Resource
      klass.send :extend, ClassMethods
    end

    module ClassMethods

      # Return the default repository name for this model.
      def default_repository_name
        :monkey_business
      end

    end

  end

  DataMapper.setup(:monkey_business,
    "yaml:#{File.expand_path '~/.monkey/business'}").resource_naming_convention =
    DataMapper::NamingConventions::Resource::UnderscoredAndPluralizedWithoutModule

  # XXX: DataMapper requires a default repository
  unless DataMapper::Repository.adapters.has_key? :default
    DataMapper.setup :default, 'sqlite::memory:'
  end

end
