
module Pcut

  class RangeIndex

    FORMAT = %r/\A\s*(\-)?(\d+)(\-)?\s*\z/

    attr_reader :index

    def initialize(index, backward, forward)
      unless index.is_a?(Fixnum)
        raise ArgumentError, "invalid index: #{index}"
      end
      unless backward == true || backward == false
        raise ArgumentError, "invalid backward spec: #{backward}"
      end
      unless forward == true || forward == false
        raise ArgumentError, "invalid forward spec: #{forward}"
      end

      @index    = index
      @backward = backward
      @forward  = forward
    end

    def self.parse(str)
      unless str.is_a?(String)
        raise ArgumentError, "#{str.to_s} is not string"
      end
      unless str =~ FORMAT
        raise ArgumentError, "invalid range index expression: #{str}"
      end

      backward = $1 ? true : false
      forward  = $3 ? true : false
      index    = $2.to_i

      if backward && forward
        raise ArgumentError, "backward, forward both specified: #{str}"
      end
      if 0 == index
        raise ArgumentError, "zero cannot be specified: #{str}"
      end

      self.new(index, backward, forward)
    end

    def include_backward?
      @backward
    end

    def include_forward?
      @forward
    end

    def to_s
      "%s%d%s" % [
        include_backward? ? "-" : "",
        @index,
        include_forward?  ? "-" : "",
      ]
    end

  end

end

