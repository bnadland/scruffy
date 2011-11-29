package Scruffy::Data::Issues;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.01';

use base 'Exporter';
our @EXPORT = qw( add_issue get_issue get_history change_priority change_state get_backlog get_progress get_waiting get_completed);

use Carp qw(croak);
use POSIX;
use Redis;

# parameter: issue_id, line_of history
# not exported
sub history {
	my ($issue_id, $history) = @_;
	unless ($issue_id) {
		croak('You need to pass the issue_id as a parameter.');
		return;
	}

	unless ($history) {
		croak('You need to pass the string you want to add to the history as second parameter.');
		return;
	}

	my $redis = db();

	$redis->rpush("history:$issue_id", POSIX::strftime("%Y-%m-%d %H:%M", localtime)." ".$history);
};

# returns: redis connection
# not exported
sub db {
	my $redis = Redis->new(encoding => undef);
	unless ($redis) {
		croak('Cannot connect to redis.');
		return;
	}
	return $redis;
};

# parameter: description, created_by
# optional: priority
sub add_issue {
	my ($description, $created_by, $priority) = @_;
	unless ($description ) {
		croak('You need to pass a description of the issue.');
		return;
	}
	unless ($created_by) {
		croak('You need to pass the creator of the issue as second parameter.');
		return;
	}

	$priority ||= "normal";

	my $redis = db();	
	
	my $id = $redis->incr("issues_id");
  $redis->hmset("issue:".$id, "description", $description, "created_by", $created_by, "priority", $priority, "state", "backlog");
  $redis->rpush("backlog:$priority", "$id");
	history("$id", "added to backlog with $priority");
};

# parameter: issue_id
# returns: hashref
sub get_issue {
	my ($issue_id) = @_;
	unless ($issue_id) {
		croak('You need to pass the issue_id as parameter.');
		return;
	};

	my $redis = db();
	
	my $result = $redis->hgetall("issue:$issue_id");
	my %result = @$result;
	return \%result;
};

# parameter: issue_id
# returns: list_of timestamped lines (maximum 1000 lines)
sub get_history {
	my ($issue_id) = @_;
	unless ($issue_id) {
		croak('You need to pass the issue_id as parameter.');
		return;
	}
	
	my $redis = db();

	return $redis->lrange("history:$issue_id", "0", "1000");
};

# parameter: issue_id, priority
sub change_priority {
	my ($issue_id, $priority) = @_;
	unless ($issue_id) {
		croak('You need to pass the issue_id as parameter.');
		return;
	}

	my $redis = db();

	$redis->hset("issue:$issue_id", "priority", "$priority");
	history("$issue_id", "changed priority to $priority");
}

# parameter: issue_id, state
sub change_state {
	my ($issue_id, $state) = @_;
	unless ($issue_id ) {
		croak('You need to pass the issue_id as parameter.');
    return;
  }

	unless ($state) {
		croak('You need to pass the state as second parameter.');
		return;
	}
	
	my $redis = db();

	my $priority  = $redis->hget("issue:$issue_id", "priority");
	my $old_state = $redis->hget("issue:$issue_id", "state");
	
	$redis->hset("issue:$issue_id", "state", "$state");
	$redis->lrem("$old_state", "0", "$issue_id");
	$redis->rpush("$state:$priority", "$issue_id");
	history("$issue_id", "changed state from $old_state to $state");
};

# parameter: none
# returns: list_of issue_ids
sub get_backlog {
	my $redis = db();
	my $backlog = ();
	foreach my $queue ($redis->keys("backlog:*")) {
		my $len  = $redis->llen("$queue");
		my $temp = $redis->lrange("$queue", "0", "$len");
		push(@$backlog, @$temp);
	}
	return $backlog;
};

sub get_progress {
	my $redis = db();
	my $progress = ();
	foreach my $queue ($redis->keys("progress:*")) {
		my $len  = $redis->llen("$queue");
		my $temp = $redis->lrange("$queue", "0", "$len");
		push(@$progress, @$temp);
	};
	return $progress;
};

sub get_waiting {
	my $redis = db();
	my $waiting = ();
	foreach my $queue ($redis->keys("waiting:*")) {
		my $len  = $redis->llen("$queue");
		my $temp = $redis->lrange("$queue", "0", "$len");
		push(@$waiting, @$temp);
	};
	return $waiting;
};

sub get_completed {
	my $redis = db();
	my $completed = ();
	foreach my $queue ($redis->keys("completed:*")) {
		my $len  = $redis->llen("$queue");
		my $temp = $redis->lrange("$queue", "0", "$len");
		push(@$completed, @$temp);
	};
	return $completed;
};

__END__;

=head1 NAME

Scruffy::Data::Issues - The database backend code for Scruffy

=head1 SYNOPSIS

	use Scruffy::Data::Issues;
	my @backlog = get_backlog();
	if( @backlog ) { print "We still have something to do!\n"; };

=head1 DESCRIPTION

This is an interface to all the issues and fields on your Scruffy board.

=head1 AUTHOR

Benjamin Nadland <benjamin.nadland@freenet.de>

=head1 LICENSE

Copyright (c) 2011 Benjamin Nadland <benjamin.nadland@freenet.de>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
