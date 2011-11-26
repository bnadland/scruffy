use Test::More;
use Scruffy::Data::Issues;

# create pristine test environment
# Warning: This flushes the database!
Scruffy::Data::Issues::db()->flushdb();

# add an issue to the database
ok(add_issue("foo", "bar"));

# check if the backlog contains one item
ok(get_backlog());

# get arrayref of issue 1
my $issue = get_issue("1");
ok($issue); 

# check description
is($issue->[1], "foo");

# check created_by
is($issue->[3], "bar");

done_testing();
