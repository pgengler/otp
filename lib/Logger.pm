package Logger;

use strict;

use base 'Exporter';

use constant {
  FATAL => 1,
  ERROR => 2,
  WARN  => 3,
  INFO  => 4,
  DEBUG => 5,
};
use constant DEFAULT_LEVEL => WARN;

our @EXPORT_OK = qw/
  FATAL ERROR WARN INFO DEBUG
/;
our %EXPORT_TAGS = (
  'levels' => [ qw/ FATAL ERROR WARN INFO DEBUG / ],
);

my $_display_labels = { };
foreach my $level_name (@{ $EXPORT_TAGS{'levels'} }) {
  no strict 'refs';
  my $level = $level_name->();
  $_display_labels->{ $level } = $level_name;
}

our $_instances = { };

sub new()
{
  my $class = shift;
  my ($name, $level) = @_;

  if (not exists $_instances->{ $name }) {
    $_instances->{ $name } = bless {
      '_level' => $level || DEFAULT_LEVEL,
    }, $class;
  }

  return $_instances->{ $name };
}

sub debug()
{
  my $self = shift;
  my ($format, @parameters) = @_;

  $self->_log(DEBUG, $format, @parameters);
}

sub error()
{
  my $self = shift;
  my ($format, @parameters) = @_;

  $self->_log(ERROR, $format, @parameters);
}

sub fatal()
{
  my $self = shift;
  my ($format, @parameters) = @_;

  $self->_log(FATAL, $format, @parameters);
}

sub info()
{
  my $self = shift;
  my ($format, @parameters) = @_;

  $self->_log(INFO, $format, @parameters);
}

sub warn()
{
  my $self = shift;
  my ($format, @parameters) = @_;

  $self->_log(WARN, $format, @parameters);
}

sub _log()
{
  my $self = shift;
  my ($level, $format, @parameters) = @_;

  if ($self->{'_level'} >= $level) {
    my @caller = caller(1);

    local $| = 1;

    printf '[%s] %s:%d: %s: ', scalar localtime, $caller[1], $caller[2], $_display_labels->{ $level };
    printf STDERR $format, @parameters;
    print STDERR "\n";
  }
}


1;
