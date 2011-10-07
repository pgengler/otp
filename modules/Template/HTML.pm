package Template::HTML;

use strict;

use base 'Template::Core';

sub new()
{
  my $class = shift;
  my ($name) = @_;

  my $self = $class->SUPER::new($name);
  $self->{'WRAPPER'} = 'layouts/application.html.tt2';

  return bless $self, $class;
}

1;
