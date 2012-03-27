package Scruffy;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Routes
  my $r = $self->routes;

  # Normal route to controller
  $r->route('/')->to('web#index');
	$r->route('/add')->to('web#add_issue');
	$r->route('/backlog')->to('web#backlog');
	$r->route('/progress')->to('web#progress');
	$r->route('/waiting')->to('web#waiting');
	$r->route('/completed')->to('web#completed');
}

1;
