
require 'pcut/line_parser'

describe Pcut::LineParser do

  before(:each) do
    @parser = Pcut::LineParser.new
  end

  it 'can parse plain line' do
    result = @parser.parse("foo\tbar\tbuz")
    result.size.should == 3
    result[0].should == "foo"
    result[1].should == "bar"
    result[2].should == "buz"
  end

  it 'returns empty array for empty string' do
    @parser.parse("").should == []
  end

  it 'returns one element array for string without delimiter' do
    str = "string_without_delimiter"
    @parser.parse(str).should == [str]
  end

  it 'can handle continuous delimiters' do
    result = @parser.parse("one\t\ttwo\t\t\tthree")
    result.size.should == 6
    result[0].should == "one"
    result[1].should == nil
    result[2].should == "two"
    result[3].should == nil
    result[4].should == nil
    result[5].should == "three"
  end

  it 'cares about pre/post delimiters' do
    result = @parser.parse("\t\tfolk\tspoon\t\t\t")
    result[0].should == nil
    result[1].should == nil
    result[2].should == "folk"
    result[3].should == "spoon"
    result[4].should == nil
    result[5].should == nil
  end

  it 'can change delimiter' do
    result = @parser.parse("foo\tbar\thoge,fuga")
    result.should == ["foo", "bar", "hoge,fuga"]

    @parser.set_delimiter(",")
    result = @parser.parse("foo bar hoge,fuga")
    result.should == ["foo bar hoge", "fuga"]
  end

  it 'raise error with invalid delimiter' do
    lambda {
      @parser.set_delimiter(nil)
    }.should raise_error(ArgumentError)

    lambda {
      @parser.set_delimiter("")
    }.should raise_error(ArgumentError)

    lambda {
      @parser.set_delimiter("ab")
    }.should raise_error(ArgumentError)
  end

  describe 'quote guard' do

    it 'can set_quote_guard' do
      @parser.set_quote_guard(Pcut::LineParser::DOUBLE_QUOTE)
      @parser.quote_guard.keys.sort.should == [
        Pcut::LineParser::DOUBLE_QUOTE]

      @parser.set_quote_guard(Pcut::LineParser::SINGLE_QUOTE)
      @parser.quote_guard.keys.sort.should == [
        Pcut::LineParser::DOUBLE_QUOTE,
        Pcut::LineParser::SINGLE_QUOTE
      ]
      @parser.set_quote_guard("[")
      @parser.quote_guard.keys.sort.should == [
        Pcut::LineParser::DOUBLE_QUOTE,
        Pcut::LineParser::SINGLE_QUOTE,
        "["
      ]
    end

    it 'understands quoter shortcuts' do
      @parser.set_quote_guard("D")
      @parser.set_delimiter(" ")
      result = @parser.parse("foo \"bar baz\" hoge") 
      result.should == [
        "foo",
        "bar baz",
        "hoge"
      ]
      @parser.set_quote_guard("S")
      result = @parser.parse("foo 'bar baz' hoge") 
      result.should == [
        "foo",
        "bar baz",
        "hoge"
      ]
    end

    it 'can keep quotes' do
      @parser.keep_quotes.should be_false

      @parser.set_delimiter(" ")
      @parser.set_quote_guard("[")
      result = @parser.parse("foo bar [hoge fuga] baz")
      result.should == ["foo", "bar", "hoge fuga", "baz"]

      @parser.keep_quotes = true
      result = @parser.parse("foo bar [hoge fuga] baz")
      result.should == ["foo", "bar", "[hoge fuga]", "baz"]
    end

    it 'raises error if quote letter is invalid' do
      lambda {
        @parser.set_quote_guard("A")
      }.should raise_error(ArgumentError)

      lambda {
        @parser.set_quote_guard()
      }.should raise_error(ArgumentError)
    end

    it 'can parse line with quote guard' do
      @parser.set_quote_guard(Pcut::LineParser::DOUBLE_QUOTE)
      @parser.set_delimiter(" ")
      @parser.parse('172cm 62kg "Nakano Kyohei" Male')\
        .should == ['172cm', '62kg', 'Nakano Kyohei', 'Male']

      @parser.set_quote_guard("(")
      @parser.parse('Foo (Bar, Buz) Hoge')\
        .should == ['Foo', 'Bar, Buz', 'Hoge']
    end

    it 'can parse line with multiple quote guard' do
      @parser.set_quote_guard(Pcut::LineParser::DOUBLE_QUOTE)
      @parser.set_delimiter(" ")
      @parser.set_quote_guard("(")
      @parser.set_quote_guard("[")
      result = @parser.parse(
          'Bonar "Nakano Kyohei" [Software Engineer] (172 62)')
      result = [
        "Bonar",
        "Nakano Kyohei",
        "Software Engineer",
        "172 62"
      ]
    end

    it 'ignores quotes which is not specified' do
      @parser.set_quote_guard("(")
      @parser.set_delimiter(" ")
      result = @parser.parse("\"Nakano Kyohei\" (172 62)")
      result.should == [
        '"Nakano',
        'Kyohei"',
        '172 62'
      ]
    end

    it 'treat quoting char as normal char in quoted section' do
      @parser.set_quote_guard(Pcut::LineParser::DOUBLE_QUOTE)
      @parser.set_quote_guard(Pcut::LineParser::SINGLE_QUOTE)
      @parser.set_quote_guard("(")
      @parser.set_delimiter(" ")

      result = @parser.parse("123 \"Nakano 'aka bonar' Kyohei (32)\" engineer")
      result.should == [
        "123",
        "Nakano 'aka bonar' Kyohei (32)",
        "engineer"
      ]
    end

  end

  it 'skips continuous delimiters if needed' do
    @parser.skip_continuous_delimiters = true
    @parser.set_delimiter(" ")
    result = @parser.parse("1979   8  23   bonar   ")
    result.should == ['1979', '8', '23', 'bonar']
  end

  describe 'real world sample' do

    before(:each) do
      @sample1 = '127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326'
    end

    it 'case 1' do
      @parser.set_delimiter(" ")
      result = @parser.parse(@sample1)
      result[0].should == '127.0.0.1'
      result[1].should == '-'
      result[2].should == 'frank'
      result[3].should == '[10/Oct/2000:13:55:36'
      result[4].should == '-0700]'
      result[5].should == '"GET'
      result[6].should == '/apache_pb.gif'
      result[7].should == 'HTTP/1.0"'
      result[8].should == '200'
      result[9].should == '2326'
    end

    it 'case 1 with quoting' do
      @parser.set_delimiter(" ")
      @parser.set_quote_guard("\"")
      @parser.set_quote_guard("[")
      result = @parser.parse(@sample1)
      result[0].should == '127.0.0.1'
      result[1].should == '-'
      result[2].should == 'frank'
      result[3].should == '10/Oct/2000:13:55:36 -0700'
      result[4].should == 'GET /apache_pb.gif HTTP/1.0'
      result[5].should == '200'
      result[6].should == '2326'
    end

  end

end

