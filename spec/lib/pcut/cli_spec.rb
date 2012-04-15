
require 'pcut/cli'

describe Pcut::CLI do

  before(:each) do
    @cli = Pcut::CLI.new
  end

  describe 'parse_field' do

    it 'can parse single index' do
      targets = @cli.parse_field("3")
      targets.size.should == 1
      targets[0][0].index.should == 3
      targets[0][1].should == []
    end

    it 'can parse multi index' do
      targets = @cli.parse_field("-4,5-")
      targets.size.should == 2
      targets[0][0].index.should == 4
      targets[0][1].should == []
      targets[1][0].index.should == 5
      targets[1][1].should == []
    end

    it 'can parse index with sub queries' do
      targets = @cli.parse_field("-4,3.[/ /,4].[/,/,12].[/./,-2],5-")
      targets.size.should == 3
      targets[0][0].index.should == 4
      targets[0][1].should == []

      targets[1][0].index.should == 3
      targets[1][1].size.should == 3
      targets[1][1][0].delimiter.should == " "
      targets[1][1][0].index.index.should == 4
      targets[1][1][1].delimiter.should == ","
      targets[1][1][1].index.index.should == 12
      targets[1][1][2].delimiter.should == "."
      targets[1][1][2].index.index.should == 2

      targets[2][0].index.should == 5
      targets[2][1].should == []
    end

  end

end

