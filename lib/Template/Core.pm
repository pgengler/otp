package Template::Core;

use strict;

use Cwd;

use Template;
use Template::Helpers;

sub new()
{
  my $class = shift;
  my ($name) = @_;

  my $self = {
    'ABSOLUTE'     => 1,
    'EVAL_PERL'    => 1,
    'INCLUDE_PATH' => cwd.'/views/',
    'INTERPOLATE'  => 1,
    'LOAD_PERL'    => 1,
    'POST_CHOMP'   => 1,
    'VARIABLES'    => Template::Helpers::_refs(),

    '_name'        => $name,
  };

  return bless $self, $class;
}

sub process()
{
  my $self = shift;
  my ($vars) = @_;
  $vars ||= { };

  my $output = '';

  if (not defined $self->{'_template'}) {
		my %self = %$self;
    $self->{'_template'} = new Template(\%self);
    $self->{'_template'}->context()->define_vmethod('list', 'contains', \&_listContains);
  }
  $self->{'_template'}->process(cwd . '/views/' . $self->{'_name'}, $vars, \$output) or die $self->{'_template'}->error();

  return $output;
}

sub error()
{
  my $self = shift;

  return $self->{'_template'}->error();
}

#####################
## METHODS PASSED TO TEMPLATES
#####################

sub _listContains($$)
{
  my ($list, $find) = @_;

  return 0 unless $list && ref($list) eq 'ARRAY';

  foreach my $item (@$list) {
    return 1 if $item eq $find;
  }
  return 0;
}

1;
