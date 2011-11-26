use Test::More;
use Scruffy::Data::Issues;

# Dependency: We need redis-server running!

# add an issue to the database
ok(add_issue("it isn't working", "foo@bar.com"));
# check if the backlog contains at least one item
ok(get_backlog());

done_testing();
