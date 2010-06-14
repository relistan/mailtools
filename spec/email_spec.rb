require 'mbox'

describe Email do

	before :each do
		mbox = Mbox.new 'spec/fixtures/enron.mbox'
		@mail = mbox.parse[4]
		
	end

	it "should parse header and body properly" do
		@mail.parse.should_not be_nil
		@mail.header.should have(15).items
		@mail.body.should have(31).items
	end

	it "should have a Subject" do
		@mail.parse.Subject.should include('Upcoming Hedging and Trading Classes, Houston')
	end

	it "should have a date" do
		@mail.parse.Date.should == '08-Oct-2001 21:03:25 +0000'
	end

	it "should have a From" do
		@mail.parse.From.should == 'jennifersmith@kaseco.com'
	end

	it "should handle unrecognized headers" do
		@mail.parse
		@mail.X_folder.should_not be_nil
	end

	it "should take varargs as the initial contents" do
		msg = [
			"From enron@example.com 08-Oct-2001 21:03:25 +0000", 
			"To: skillingj@enron.com",
			"Date: Oct  8, 2001 14:03:25",
			"",
			"Body text."
		]
		mail = Email.new *msg
		mail.parse.should have(5).items
		mail.Date.should == '08-Oct-2001 21:03:25 +0000'
	end

end
