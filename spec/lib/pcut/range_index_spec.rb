
require 'pcut/range_index'

describe Pcut::RangeIndex do

  it 'can create instance with new' do
    index = Pcut::RangeIndex.new(1, true, false)
    index.index.should == 1
    index.include_backward?.should be_true
    index.include_forward?.should be_false

    index = Pcut::RangeIndex.new(2, false, true)
    index.index.should == 2
    index.include_backward?.should be_false
    index.include_forward?.should be_true
  end

  it 'raises error on invalid index, backward or forward' do
    lambda { Pcut::RangeIndex.new(nil, true, true) }.
      should raise_error(ArgumentError, %r/invalid index/)

    lambda { Pcut::RangeIndex.new(1, "true", true) }.
      should raise_error(ArgumentError, %r/invalid backward/)

    lambda { Pcut::RangeIndex.new(1, true, "true") }.
      should raise_error(ArgumentError, %r/invalid forward/)
  end

  it 'can parse single index string' do
    index = Pcut::RangeIndex.parse("123")
    index.index.should == 123
    index.include_backward?.should be_false
    index.include_forward?.should be_false
  end

  it 'can parse index string including backward' do
    index = Pcut::RangeIndex.parse("-92")
    index.index.should == 92
    index.include_backward?.should be_true
    index.include_forward?.should be_false
  end

  it 'can parse index string including forward' do
    index = Pcut::RangeIndex.parse("4-")
    index.index.should == 4
    index.include_backward?.should be_false
    index.include_forward?.should be_true
  end

  it 'raises error on string including both backward and forward' do
    lambda { index = Pcut::RangeIndex.parse("-5-") }.
      should raise_error(ArgumentError, %r/both specified/)
  end

  it 'raises error on zero index' do
    lambda { index = Pcut::RangeIndex.parse("0") }.
      should raise_error(ArgumentError, %r/zero/)
  end

  it 'ignores white spaces arround the target' do
    Pcut::RangeIndex.parse("  321  ").index.should == 321
    Pcut::RangeIndex.parse("  -72  ").index.should == 72
    Pcut::RangeIndex.parse("  90-  ").index.should == 90
  end

  it 'raises error on invalid string' do
    lambda { Pcut::RangeIndex.parse(nil) }.
      should raise_error(ArgumentError, %r/not string/)

    lambda { Pcut::RangeIndex.parse("1-1") }.
      should raise_error(ArgumentError, %r/invalid range index expression/)
  end

  it 'implements to_s' do
    Pcut::RangeIndex.new(2, false, false).to_s.should == "2"
    Pcut::RangeIndex.new(4, true, false).to_s.should == "-4"
    Pcut::RangeIndex.new(6, false, true).to_s.should == "6-"
  end

end
