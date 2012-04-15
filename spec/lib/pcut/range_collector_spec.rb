
require 'pcut/range_collector'

describe Pcut::RangeCollector do

  before(:each) do
    @array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  end

  it 'collects values with range index' do
    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("1")).
      should == [1]

    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("5")).
      should == [5]

    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("10")).
      should == [10]

    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("11")).
      should == []
  end

  it 'collects values with backward range index' do
    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("-1")).
      should == [1]

    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("-4")).
      should == [1, 2, 3, 4]

    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("-8")).
      should == [1, 2, 3, 4, 5, 6, 7, 8]

    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("-10")).
      should == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("-11")).
      should == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  end

  it 'collects values with forward range index' do
    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("1-")).
      should == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("5-")).
      should == [5, 6, 7, 8, 9, 10]

    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("10-")).
      should == [10]

    Pcut::RangeCollector.collect(@array, Pcut::RangeIndex.parse("11-")).
      should == []
  end

  it 'raises error on invalid input' do
    lambda {
      Pcut::RangeCollector.collect(nil, Pcut::RangeIndex.parse("5-"))
    }.should raise_error(ArgumentError, %r/not an array/)

    lambda { Pcut::RangeCollector.collect(nil, 5) }.
      should raise_error(ArgumentError, %r/not an array/)
  end

end

