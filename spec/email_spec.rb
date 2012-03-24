$:<< File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mbox'

fixtures_path = File.join(File.dirname(__FILE__), 'fixtures')
describe Email do

  let(:mail) do
    data = File.read(File.join(fixtures_path, 'enron.mbox')).split(/\n/)
	Email.from_contents(data[339..385])
  end

  it "should separate the header and body properly" do
    mail.header.should have(15).items
    mail.body.should have(30).items
	mail.should have(45).items
  end

  it "should have a Subject" do
    mail.subject.should include('Upcoming Hedging and Trading Classes, Houston')
  end

  it "should have a date" do
    mail.date.should == '08-Oct-2001 22:03:25 +0000'
  end

  it "should have a From" do
    mail.From.should == 'jennifersmith@kaseco.com'
  end

  it "should handle unrecognized headers" do
    mail.X_folder.should_not be_nil
  end

  it "should take varargs as the initial contents" do
    msg = [
      "From enron@example.com 08-Oct-2001 21:03:25 +0000", 
      "To: skillingj@enron.com",
      "Date: Oct  8, 2001 14:03:25",
      "",
      "Body text."
    ]
    mail = Email.from_contents(msg)
    mail.should have(3).items
    mail.Date.should == '08-Oct-2001 14:03:25 +0000'
  end

end
