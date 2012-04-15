
require 'rubygems'
require 'term/ansicolor'
require 'pcut/line_parser'
require 'pcut/range_index'
require 'pcut/range_collector'
require 'pcut/query'

module Pcut

  class CLI
    include Term::ANSIColor

    attr_accessor \
      :delimiter,
      :joiner,
      :fields,
      :quote,
      :keep_quote,
      :preview,
      :vertical,
      :color
    
    def initialize
      @delimiter  = "\t"
      @joiner     = @delimiter
      @fields     = []
      @quote      = nil
      @keep_quote = false
      @preview    = false
      @vertical   = false
      @color      = true
    end

    def parse_field(str)
      targets = []

      begin
        field_parser = Pcut::LineParser.new
        field_parser.set_delimiter(",")
        field_parser.set_quote_guard("[")
        field_parser.keep_quotes = true
        fields = field_parser.parse(str)

        fields.each do |field|
          index   = nil
          queries = []

          query_parser = Pcut::LineParser.new
          query_parser.set_delimiter(".")
          query_parser.set_quote_guard("[")
          query_parser.keep_quotes = true

          if field =~ /\./
            result = query_parser.parse(field)
            first  = result.shift
            index  = Pcut::RangeIndex.parse(first)
            result.each do |query_str|
              queries << Pcut::Query.parse(query_str)
            end
          else
            index = Pcut::RangeIndex.parse(field)
          end
          targets << [index, queries]
        end
      rescue => e
        STDOUT.puts e.to_s
        exit(1)
      end
      targets
    end

    def start(filepath)
      begin
        parser = Pcut::LineParser.new
        parser.set_delimiter(@delimiter)
        @quote.each_char { |c| parser.set_quote_guard(c) } if @quote
        parser.keep_quotes = true if @keep_quote
      rescue => e
        STDOUT.puts e.to_s
        exit(1)
      end

      io = nil
      if filepath
        begin
          if File.directory?(filepath)
            raise ArgumentError, "#{filepath} is directory"
          end
          io = File.open(filepath, 'r')
        rescue => e
          $stdout.puts e.to_s
          exit(1)
        end
      end
      io ||= STDIN
      io.each_line do |line|
        line.chomp!
        buff   = [] # selected fields
        result = parser.parse(line)

        joiner = @vertical ? "\n" : @joiner

        # apply -f fields specification
        # (value pickup)
        if !@fields.empty?
          @fields.each do |setting|
            index   = setting[0]
            queries = setting[1]
            value = Pcut::RangeCollector.collect(result, index).join(@joiner)
            if queries.empty?
              buff << index_labeL(index.index) + (value || "")
            else
              queries.each do |query|
                last if value.nil?
                sliced = Pcut::RangeCollector.collect(
                  value.split(query.delimiter), query.index)
                value = sliced.join(query.delimiter)
              end
              buff << query_label(index.index, queries) + (value || "")
            end
          end
        # no @fields is "all the fields"
        else
          result.each_with_index do |field, index|
            buff << index_labeL(index + 1) + (field || "")
          end
        end

        puts buff.join(joiner)
        puts "" if @vertical
      end
      exit(0)
    end

    def index_labeL(index)
      return "" unless @preview
      (@color ? red : '') + "[" +
      (@color ? yellow : '' ) + "#{index}" + 
      (@color ? red : '') + "]" + (@color ? reset : '')
    end

    def query_label(index, queries)
      return "" unless @preview
      query_str = queries.each { |q| q.to_s }.join(".")

      (@color ? red : '') + "[" +
      (@color ? yellow : '' ) + "#{index}" +
      (@color ? green : '' ) + ".#{query_str}" +
      (@color ? red : '') + "]" + (@color ? reset : '')
    end

  end

end

