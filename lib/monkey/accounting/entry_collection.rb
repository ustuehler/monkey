require 'forwardable'
require 'monkey/accounting'

module Monkey::Accounting

  # Collection of ledger entries.  This can be used much like a simple Array
  # but will manage entry id's as entries are added and removed from the list.
  class EntryCollection
    extend Forwardable
    def_delegators :@entries, :first, :last, :[], :each, :sort, :sort_by,
      :select, :reject, :collect, :map, :count, :size, :any?, :all?, :none?

    # Creates an empty collection of accounting {Entry} objects.
    def initialize
      @entries = []
    end

    # Duplicates the @entries instance variable so that the new copy becomes
    # independent of the original collection.
    def initialize_copy(other)
      @entries = other.instance_variable_get(:@entries).dup
    end

    # Returns a new EntryCollection with +entries+ appended to the existing
    # entries in the collection.
    def +(entries)
      dup = self.dup
      entries.each { |e| dup << e }
      dup
    end

    # Removes an entry from the collection.
    def >>(entry)
      unless entry.is_a?(Entry)
        raise ArgumentError, "object is not an #{Entry}: #{entry.inspect}"
      end

      if entry.id.nil?
        raise RuntimeError, "entry has no id: #{entry.inspect}"
      end

      # Remove the entry and unset the entry.id.
      @entries.delete_at entry.id
      entry.id = nil

      # Renumber the existing entries and return the removed entry.
      @entries.each_with_index { |e, i| e.id = i }
      entry
    end

    # Appends a new entry to the collection.
    def <<(entry)
      unless entry.is_a?(Entry)
        raise ArgumentError, "object is not an #{Entry}: #{entry.inspect}"
      end

      unless entry.id.nil?
        raise RuntimeError, "entry already has an id: #{entry.inspect}"
      end

      entry.id = @entries.size
      @entries << entry
      self
    end
  end

end
