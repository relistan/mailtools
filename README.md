# mailtools

### Functionality
Two Ruby classes are contained in this project and some executables
for doing some useful things with Unix Mbox files.  The two included
classes parse Mbox files and Email messages and make them easy to
deal with from Ruby.  They are dead simple and are read-only.

Also included are a simple set of tools for parsing a UNIX-style
mbox file and for uploading the messages from an mbox file to a
remote IMAP server.  This has been used and tested against Google
Gmail and is good for migrating old archived mail to Gmail or other
IMAP servers that accept appending messages to your mailboxes.

There are miscellaneous other pieces of functionality here,
including the ability to convert maildir to mbox format.  This
could be useful for uploading maildir to an IMAP server as well.

### Running
You can test if mbox.rb will parse your mailbox correctly before
attempting an upload by running:

<code>
bin/mboxreader.rb yourmailfilehere
</code>

A command line like this should work for uploading to Gmail:

<code>
bin/mbox2imap.rb -f yourmailfilehere -h imap.gmail.com:993 -p yourpass -u youruname -m MyOldMail -s -r
</code>

###Perl
The included Ruby classes are also mirrored here as two Moose
classes in Perl.  bin/mbox.pl contains all of the functionality.
