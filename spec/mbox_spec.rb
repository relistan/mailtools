$:<< File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mbox'

fixture = File.join(File.dirname(__FILE__), 'fixtures', 'enron.mbox')

describe Mbox do

  let(:mbox) { Mbox.new(fixture) }

  it "should find all the messages in an mbox file" do
    mbox.should have(17).items
	mbox.should_not be_empty
  end

  it "should display the index of the mbox file" do
    mbox.index_array.should include('0003: Upcoming Hedging and Trading Classes, Houston      | 08-Oct-2001 22:03:25 +0000')
  end

  it "should correctly enumerate an mbox" do
    items = mbox.select { |x| x.index == 2 }
	items.first.subject.should == "MS 150"
  end

end
