use Test::More;
use Scruffy::Data::Issues;

# create pristine test environment
# Warning: This flushes the database!
Scruffy::Data::Issues::db()->flushdb();

my $issue;
my $history;

# check that fields are empty
ok(!get_backlog());
ok(!get_progress());
ok(!get_waiting());
ok(!get_completed());

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

# check history of issue 1
$history = get_history("1");
ok($history);

# check history of entry into backlog
like($history->[0], qr/backlog/);

# assign issue 1
assign_to("1", "baz");
$issue = get_issue("1");
is($issue->{"state"}, "progress");

# check if progress contains one issue
ok(get_progress());

# wait issue 1
wait_on("1", "wait for bar to confirm new findings");
$issue = get_issue("1");
is($issue->{"state"}, "waiting");

# check if waiting contains one issue
ok(get_waiting());

# complete issue 1
complete("1");
$issue = get_issue("1");
is($issue->{"state"}, "completed");

# check if completed contains an issue
ok(get_completed());

done_testing();
