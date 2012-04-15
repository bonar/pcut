
module Pcut

  class LineParser

    DOUBLE_QUOTE = "\""
    SINGLE_QUOTE = "'"

    QUOTES = {
      DOUBLE_QUOTE => [DOUBLE_QUOTE, DOUBLE_QUOTE],
      SINGLE_QUOTE => [SINGLE_QUOTE, SINGLE_QUOTE],
      "D" => [DOUBLE_QUOTE, DOUBLE_QUOTE], # shortcut
      "S" => [SINGLE_QUOTE, SINGLE_QUOTE], # shortcut
      "[" => ["[", "]"],
      "(" => ["(", ")"],
      "<" => ["<", ">"]
    }
    DELIMITER = "\t"

    attr_reader :quote_guard
    attr_accessor :keep_quotes

    def initialize
      @quote_guard  = {}
      @delimiter    = DELIMITER
      @keep_quotes  = false # do not delete quoting chars
    end

    def set_quote_guard(quote)
      unless QUOTES.has_key?(quote)
        raise ArgumentError, "invalid quote: #{quote}"
      end
      @quote_guard[QUOTES[quote].first] = QUOTES[quote]
    end

    def set_delimiter(char)
      if !char.is_a?(String) || char.size != 1
        raise ArgumentError, "invalid delimiter: #{char.to_s}"
      end
      @delimiter = char
    end

    def parse(str)
      buffer = nil
      previous_char = nil
      current_quote = nil
      finalizer     = nil
      partials = []

      str.each_char do |c|

        # check starting quote
        if @quote_guard.include?(c) &&
          previous_char != "\\" # not escaped
          starter = @quote_guard[c].first

          if !current_quote && c == starter
            current_quote = c
            finalizer = @quote_guard[c].last
            if @keep_quotes
              buffer ||= ""
              buffer += c
            end
            next
          end
        end

        # check end of quote
        if current_quote && c == finalizer
          current_quote = nil
          finalizer     = nil
          if @keep_quotes
            buffer ||= ""
            buffer += c
          end
          next
        end

        if !current_quote && c == @delimiter
          partials << buffer
          buffer = nil
        elsif current_quote || c != @delimiter
          buffer ||= ""
          buffer += c
        end
        previous_char = c
      end
      partials << buffer if buffer
      partials
    end

  end

end

