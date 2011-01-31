#!/usr/bin/perl

use strict;
use Test::More tests => 7;
use File::Basename qw/dirname/;

my $basedir = dirname(__FILE__) . "/..";
my $mbox_file = "$basedir/mbox.pl";
require $mbox_file;

# New Mailbox
my $mbox = new_ok "Mbox";
$mbox->filename("$basedir/spec/fixtures/enron.mbox");
is $mbox->size(), 0, "Unparsed mailbox is empty";

# Parses Mailbox
$mbox->parse();
is $mbox->size(), 17, "Parsed mailbox contains 17 messages";
isa_ok $mbox->get(1), 'Email', "The object Mbox returned";

# Parses messages
like join("\n", @{ $mbox->get(4)->parse->body }), qr/funniest things I've ever/, "Fetches the correct message";
like $mbox->get(5)->parse->header('Subject'), qr/new members/, "Parses message Subject header properly";
is $mbox->get(6)->parse->header('Date'), "Mon, 8 Oct 2001 01:36:38 -0700 (PDT)", "Parses message Date header properly";
