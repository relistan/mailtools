require 'mbox'

describe Mbox do

	before :each do
		@mbox = Mbox.new 'spec/fixtures/enron.mbox'
		@mbox.parse
	end

	it "should parse the mbox text" do
		# Just test the before each action
	end

	it "should find all the messages in an mbox file" do
		@mbox.should have(17).items
	end

	it "should display the index of the mbox file" do
		old = $stdout
		$stdout = StringIO.new
		@mbox.index
		$stdout.string.should include('0003: Upcoming Hedging and Trading Classes, Houston      | 08-Oct-2001 21:03:25 +0000')
		$stdout = old
	end

end
