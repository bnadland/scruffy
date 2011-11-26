package Scruffy::Web;
use Mojo::Base 'Mojolicious::Controller';

sub index {
  my $self = shift;

	$self->stash( message => 'Welcome to the Mojolicious real-time web framework!');
	$self->render();
}

1;
