
require 'pcut/range_index'

module Pcut

  class Query

    FORMAT = %r{\A\s*\[\s*/\\?(.)/\s*,\s*([0-9\-]+)\s*\]\z}

    attr_accessor :delimiter, :index

    def initialize(delimiter, index)
      if !delimiter.is_a?(String) || delimiter.size != 1
        raise ArgumentError, "invalid delimiter: #{delimiter}"
      end
      if !index.is_a?(Pcut::RangeIndex)
        raise ArgumentError, "index must be a RangeIndex: #{index}"
      end

      @delimiter = delimiter
      @index     = index
    end

    def self.parse(str)
      unless str.is_a?(String)
        raise ArgumentError, "#{str.to_s} is not a string"
      end
      unless str =~ FORMAT
        raise ArgumentError, "invalid format: #{str}"
      end
      index = Pcut::RangeIndex.parse($2)
      self.new($1, index)
    end

    def to_s
      "[/%s/,%s]" % [@delimiter, @index.to_s]
    end
  
  end

end
