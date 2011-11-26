package Scruffy::Data::Issues;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.01';

use base 'Exporter';
our @EXPORT = qw( add_issue get_issue change_priority assign_issue wait complete get_backlog get_progress get_waiting get_completed);

use Carp 'croak';

use Redis;

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
	my ($description, $created_by) = @_;
	unless ($description ) {
		croak('You need to pass a description of the issue.');
		return;
	}
	unless ($created_by) {
		croak('You need to pass the creator of the issue as second parameter.');
		return;
	}

	my $priority = shift || "normal";

	my $redis = db();	
	
	my $id = $redis->incr("issues_id");
  $redis->hmset("issue:".$id, "description", $description, "created_by", $created_by, "priority", $priority);
  $redis->rpush("backlog", "issue:" . $id);
};

# parameter: issue_id
# returns: hashref
sub get_issue {
	my $issue_id = shift;
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
sub change_priority {...}
sub assign_issue    {...}
sub wait            {...}
sub complete        {...}

# parameter: none
# optional: number of issues
# returns: list_of issue_ids
sub get_backlog   {
	my $number_of_issues = shift || 100;
	my $redis = db();
	return $redis->lrange("backlog", "0", "$number_of_issues");
};
sub get_progress  {...}
sub get_waiting   {...}
sub get_completed {...}

__END__;

=head1 NAME

Scruffy::Data::Issues - The database backend code for Scruffy

=head1 SYNOPSIS

	use Scruffy::Data::Issues;
	my @backlog = get_backlog();
	if( @backlog ) { print "We still have something to do!\n"; };

=head1 DESCRIPTION

This is an interface to all the issues and fields on your Scruffy board.

=head2 Subroutines

The following subroutines are exported by default:

=head3 add_issue()

=head3 get_issue()

=head3 change_priority()

=head3 assign_issue()

=head3 wait()

=head3 complete()

=head3 get_backlog()

=head3 get_progress()

=head3 get_waiting()

=head3 get_completed()

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
