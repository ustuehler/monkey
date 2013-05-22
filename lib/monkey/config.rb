require 'yaml'

module Monkey

  class Config

    def self.load_file(filename)
      Config.new YAML.load_file(filename)
    end

    def initialize(options = {})
      options.each_pair do |option, value|
        if respond_to? "#{option}="
          send("#{option}=", value)
        elsif has_section? option
          section = class_for_section(option).new(value)
          (class << self; self; end).class_eval do
            define_method(option) { section }
          end
        else
          raise "invalid configuration option: #{option}"
        end
      end
    end

    def method_missing(method_name, *args)
      if has_section? method_name
        section = class_for_section(method_name).new
        (class << self; self; end).class_eval do
          define_method(method_name) { section }
        end
        section
      else
        super
      end
    end

    private

    def has_section?(section)
      class_for_section(section) != nil
    end

    def class_for_section(section)
      # TODO: CamelCase the section when capitalization isn't enough
      section_const = section.capitalize
      parent_module = Module.nesting[1]
      if parent_module.const_defined? section_const
        section_module = parent_module.const_get(section_const)
        if section_module.const_defined? :Config
          return section_module.const_get :Config
        end
      end
      nil
    end

  end

end
