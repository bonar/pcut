
require 'pcut/line_parser'

describe Pcut::LineParser do

  # 127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326
  # 127.0.0.1 - frank [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326 "http://www.example.com/start.html" "Mozilla/4.08 [en] (Win98; I ;Nav)"

  before(:each) do
    @parser = Pcut::LineParser.new
  end

  it 'can parse plain line' do
    result = @parser.parse("foo bar buz")
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

  it 'treats continuous delimiters as one seperator' do
    result = @parser.parse("one    two    three")
    result.size.should == 3
    result[0].should == "one"
    result[1].should == "two"
    result[2].should == "three"
  end

  it 'ignores pre/post delimiters' do
    result = @parser.parse("    folk spoon     ")
    result.size.should == 2
    result[0].should == "folk"
    result[1].should == "spoon"
  end

end

