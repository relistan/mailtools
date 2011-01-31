#!/usr/bin/perl

use FileHandle;

package Email;
use Moose;
has headers => ( isa => 'HashRef',  is => 'ro', required => 1, default => sub { {} } );
has body =>    ( isa => 'ArrayRef', is => 'ro', required => 1, default => sub { [] } );
has index =>   ( isa => 'Int',      is => 'rw' );
has text =>    ( isa => 'ArrayRef', is => 'rw', required => 1, default => sub { [] } );

sub parse {
	my($self) = @_;

	if( (@{ $self->body() } > 0) || keys(%{ $self->headers() }) > 0) { return; } # Don't keep re-parsing

	my $state = 'header';
	foreach my $line (@{ $self->text() }) {
		if($line =~ /\A\Z/) { $state = 'body'; }

		if($state eq 'header') {
			if($line =~ /^\s*([^ ]+?)\s*:\s*(.+)\s*$/) {
				my $key = ($1 ~~ '' ? '' : $1);
				my $value = ($2 ~~ '' ? '' : $2);
				${ $self->headers() }{ucfirst($key)} = $value;
			}
		} elsif($state eq 'body') {
			push(@{ $self->body() }, $line);
		}
	}

	${ $self->headers() }{'Date'} ||= "UNKNOWN TIME";
	${ $self->headers() }{'Subject'} ||= "";

	return $self;
}

sub header {
	my ($self, $str) = @_;
	return ${ $self->headers() }{$str};
}

sub size {
	my($self) = @_;
	return 0 unless defined($self->text());
	return @{ $self->text() };
}

package Mbox;
use Moose;
has 'filename' => ( isa => 'Str',      is => 'rw' );
has 'mail' =>     ( isa => 'ArrayRef', is => 'ro', default => sub { [] } );

sub parse {
	my($self) = @_;
	die "Don't have a mailbox file to parse!\n" unless defined($self->filename());

	my $blank = 0;
	my $mail = new Email();
	my $i = 0;

	my $fh = new FileHandle("<" . $self->filename()) or die "Can't open " . $self->filename() . "\n";
	while(my $line = $fh->getline()) {
		if($blank && $line =~ /\AFrom .*\d{4}/) {
			push(@{ $self->mail() }, $mail) unless $mail->size() <= 0;
			$mail = new Email();
			push(@{ $mail->text() }, $line);
			$mail->index($i);
			$blank = 0;
		} else {
			$blank = ($line =~ /\A\Z/o ? 1  : 0);
			push(@{ $mail->text() }, $line) unless ($blank && $i == 0);
		}
		$i++;
	}

	push(@{ $self->mail() }, $mail) unless $mail->size() <= 0;
	return $self->mail();
}

sub size {
	my($self) = @_;
	scalar @{ $self->mail };
}

sub index {
	my($self) = @_;
	$self->parse() unless (defined($self->size()) && ($self->size != 0));
	my $i = 0;
	foreach my $message (@{ $self->mail() }) {
		next unless defined($message);
		$message->parse();
		print sprintf("%04d", $i), ": ", sprintf("%-50s", $message->header('Subject')), " | ", $message->header('Date'), "\n";
		$i++;
	}
}

sub get {
	my($self, $index) = @_;
	${ $self->mail() }[$index];
}

package main;

if($0 eq __FILE__) {
	if(@ARGV > 1) {
		my $mbox = new Mbox;
		$mbox->filename($ARGV[0]);
		$mbox->parse();
		my $mail = $mbox->get($ARGV[1])->parse();

		print "\n";
		print "From:	", $mail->header('From'), "\n";
		print "To:	", $mail->header('To'), "\n";
		print "Date:	", $mail->header('Date'), "\n";
		print "Subject: ", $mail->header('Subject'), "\n";
		print "\n";

		foreach my $line (@{ $mail->body }) {
			print "$line";
		}
	} elsif(@ARGV == 1) {
		my $mbox = new Mbox;
		$mbox->filename($ARGV[0]);
		$mbox->index();
		print "TOTAL: ", $mbox->size(), "\n";
	} else {
		print "Usage: mbox.rb mboxfilename [msg_index]\n"
	}
} else {
	1;
}
