require 'monkey/data_mapper'

module Monkey::DataMapper

  # Include this module instead of DataMapper::Resource to obtain automatic
  # multi-repository behaviour with the YAML file backend.
  #
  # Example:
  #
  #  class Monkey::Foo::Bar
  #    include Monkey::DataMapper::Resource
  #
  #    property :id, String, :key => true
  #    property :name, String
  #  end
  #
  # The example above implicitly sets up a DataMapper repository named
  # :monkey_foo, used by default for all Bar resources, which stores resources
  # in YAML files under "~/.monkey/foo".  Bar resources are thus stored in the
  # file "~/.monkey/foo/bars.yaml".
  module Resource
    def self.included(resource_class)
      # Get the parent constant from the resource class constant (e.g.,
      # Monkey::Business from Monkey::Business::Customer).
      unless (parent_name = resource_class.name =~ /::[^:]+\Z/ ? $` : nil)
        raise ArgumentError, "resource class #{resource_class.inspect} doesn't have a parent name"
      end

      # Transform the parent name (e.g., "Monkey::Business") into a DataMapper
      # repository name (e.g., :monkey_business).  In most cases the resulting
      # symbol will be as expected unless the parent name contains camel-case,
      # as in "Monkey::ProcessMail", which becomes :monkey_processmail.
      repository_name = parent_name.split('::').map {|n|
        n.downcase}.join('_').to_sym

      # Transform the parent name (e.g., "Monkey::Business") into a DataMapper
      # repository path for the YAML file backend. (e.g., "~/.monkey/business").
      repository_path = '~/.' + parent_name.split('::').map {|n|
        n.downcase}.join('/')

      # Initialize the repository unless it has already been initialized,
      # possibly elsewhere.
      unless DataMapper::Repository.adapters.has_key?(repository_name)
        repository_path = File.expand_path(repository_path)
        repository = DataMapper.setup(repository_name, "yaml:#{repository_path}")
        repository.resource_naming_convention =
          DataMapper::NamingConventions::Resource::UnderscoredAndPluralizedWithoutModule
      end

      # Include the DataMapper::Resource module.
      resource_class.send(:include, DataMapper::Resource)

      # Set the default repository name.
      resource_class.define_singleton_method(:default_repository_name) { repository_name }
    end
  end

end
