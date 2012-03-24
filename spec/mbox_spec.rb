$:<< File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mailtools/mbox'

fixture = File.join(File.dirname(__FILE__), 'fixtures', 'enron.mbox')

describe Mailtools::Mbox do

  let(:mbox) { Mailtools::Mbox.new(fixture) }

  it "should find all the messages in an mbox file" do
    mbox.should have(17).items
	mbox.should_not be_empty
  end

  it "should display the index of the mbox file" do
    mbox.index_array.should include('0003: Upcoming Hedging and Trading Classes, Houston      | 08-Oct-2001 22:03:25 +0000')
  end

  it "should act like Enumerable an mbox" do
    items = mbox.select { |x| x.index == 2 }
	items.first.subject.should == "MS 150"
  end

  it "should correctly index the emails" do
    mbox[2].index.should == 2
    mbox.last.index.should == 16 
  end

  it "should generate emails that are correctly formatted" do
    mbox[2].body[4].should =~ /I'm excited about Enron's future/
  end

  it "should raise when the file can't be found" do
    lambda { Mailtools::Mbox.new('asdf') }.should raise_error(IOError)
  end

end
