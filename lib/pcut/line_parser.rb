
module Pcut

  class LineParser

    QUOTES = ["\"", "'"]
    DELIMITER = " "

    def initialize
      @quote_guard = false
      @delimiter = DELIMITER
    end

    def parse(str)
      buffer = nil
      partials = []

      str.each_char do |c|
        if c == @delimiter && buffer
          partials << buffer
          buffer = nil
        elsif c != @delimiter
          buffer ||= ""
          buffer += c
        end
      end
      partials << buffer if buffer
      partials
    end

  end

end

