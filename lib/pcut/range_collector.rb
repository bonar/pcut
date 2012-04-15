
require 'pcut/range_index'

module Pcut

  class RangeCollector

    def self.collect(array, range_index)
      unless array.is_a?(Array)
        raise ArgumentError, "#{array.to_s} is not an array"
      end
      unless range_index.is_a?(Pcut::RangeIndex)
        raise ArgumentError, "#{range_index.to_s} is not a range_index"
      end

      return [] if array.empty?
      array_index = range_index.index - 1

      if range_index.include_backward?
        array[0..array_index]
      elsif range_index.include_forward?
        array[array_index..-1]
      else
        value = array[array_index]
        value ? [value] : []
      end
    end

  end

end
