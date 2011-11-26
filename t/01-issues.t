use Test::More;
use Scruffy::Data::Issues;

# create pristine test environment
# Warning: This flushes the database!
Scruffy::Data::Issues::db()->flushdb();

my $issue;

# add an issue to the database
ok(add_issue("foo", "bar"));

# add an issue with prioriy
ok(add_issue("foo", "bar", "priority"));

# check if the backlog contains one item
ok(get_backlog());

# get hashref of issue 1
$issue = get_issue("1");
ok($issue);

# check description
is($issue->{"description"}, "foo");

# check created_by
is($issue->{"created_by"}, "bar");

# change priority of issue 1 to "expedite"
change_priority("1", "expedite");
$issue = get_issue("1");
is($issue->{"priority"}, "expedite");

done_testing();
