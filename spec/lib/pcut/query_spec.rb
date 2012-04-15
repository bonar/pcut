
require 'pcut/query'

describe Pcut::Query do

  it 'can be initialized with delimiter and range index' do
    query = Pcut::Query.new(" ", Pcut::RangeIndex.parse("-2"))
    query.delimiter.should == " "
    query.index.index.should == 2
    query.index.include_backward?.should be_true
    query.index.include_forward?.should be_false
  end

  it 'can parse query string' do
    query = Pcut::Query.parse(%q|[/ /, -23]|)
    query.delimiter.should == " "
    query.index.index.should == 23
    query.index.include_backward?.should be_true
    query.index.include_forward?.should be_false
  end

  it 'allows white speces on parsing' do
    query = Pcut::Query.parse(%q|[  ///   ,  456-   ]|)
    query.delimiter.should == "/"
    query.index.index.should == 456
    query.index.include_backward?.should be_false
    query.index.include_forward?.should be_true
  end

  it 'raises error on bad delimiter' do
    # empty string
    lambda { Pcut::Query.parse(%q|[//, -23]|) }.
      should raise_error(ArgumentError, %r/invalid format/)
    # 2 letters string
    lambda { Pcut::Query.parse(%q|[/  /, -23]|) }.
      should raise_error(ArgumentError, %r/invalid format/)
  end

  it 'raises error on bad index expression' do
    lambda { Pcut::Query.parse(%q|[/ /, 0]|) }.
      should raise_error(ArgumentError, %r/zero/)
  end

  it 'implements to_s' do
    Pcut::Query.parse(%q|[/K/, -89]|).to_s.should == "[/K/,-89]"
    Pcut::Query.parse(%q|[/_/, 23-]|).to_s.should == "[/_/,23-]"
  end
end
