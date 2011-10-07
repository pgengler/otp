package Controller;

use strict;

use CGI;
use List::MoreUtils qw/ first_index /;

use Util qw/ :all /;

use base 'Exporter';

our @EXPORT = qw/
  beforeFilter prependBeforeFilter
/;

our $_beforeFilters = { };

sub new()
{
  my $class = shift;

  my $name = lc($class);
  $name =~ s/controller$//;

  my $self = {
    '_name'     => $name,
    '_rendered' => 0,
  };

  return bless $self, $class;
}

sub redirect()
{
  my $self = shift;

  my $url;

  if (scalar(@_) % 2 == 1) {
    # Odd number of arguments means we have a standalone path and an optional hash of options
    $url = shift;
  }
  my %options = @_;

  print CGI::redirect({
    'uri'    => $url,
    'status' => $options{'status'} || 302,
  });

  $self->{'_rendered'} = 1;
}

sub render()
{
  my $self = shift;

  my $action;
  my $vars = { };

  if (ref $_[0] eq 'HASH') {
    my @caller = caller(0);
    $action = $caller[2];
  } else {
    $action = shift;
  }

  my $vars = shift;

  $self->_renderHTML($action, $vars);

  $self->{'_rendered'} = 1;
}

sub rendered()
{
  my $self = shift;

  return $self->{'_rendered'};
}

sub _renderHTML()
{
  my $self = shift;
  my ($action, $vars) = @_;

  require CGI;
  require Template::HTML;

  my $template = new Template::HTML(sprintf('%s/%s.html.tt2', $self->{'_name'}, $action));

  print CGI::header({ 'charset' => 'utf-8' });
  print $template->process($vars);
}

sub beforeFilter($;%)
{
  my $filterSub = shift;
  my %options = @_;

  my @caller = caller();
  my $controllerName = controllerNameFromPackage($caller[0]);

  my $filterInfo = _filterInfo($filterSub, %options);

  if (not exists $_beforeFilters->{ $controllerName }) {
    $_beforeFilters->{ $controllerName } = [ ];
  }

  push @{ $_beforeFilters->{ $controllerName } }, $filterInfo;
}

sub prependBeforeFilter()
{
  my $filterSub = shift;
  my %options = @_;

  my @caller = caller();
  my $controllerName = controllerNameFromPackage($caller[0]);

  my $filterInfo = _filterInfo($filterSub, %options);

  if (not exists $_beforeFilters->{ $controllerName }) {
    $_beforeFilters->{ $controllerName } = [ ];
  }

  unshift @{ $_beforeFilters->{ $controllerName } }, $filterInfo;
}

sub _filterInfo($;%)
{
  my $filterSub = shift;
  my %options = @_;

  my $filterInfo = {
    'sub' => $filterSub,
  };

  # 'only' takes precendece over 'except' if both are specified
  if ($options{'only'} && ref($options{'only'}) eq 'ARRAY') {
    $filterInfo->{'only'} = $options{'only'};
  } elsif ($options{'except'} && ref($options{'except'}) eq 'ARRAY') {
    $filterInfo->{'except'} = $options{'except'};
  }

  return $filterInfo;
}


sub _runFilters()
{
  my $self = shift;
  my ($action) = @_;

  my $filters = $_beforeFilters->{ controllerNameFromPackage(ref($self)) } || [ ];

  foreach my $filter (@$filters) {
    if (exists $filter->{'only'} && contains($action, $filter->{'only'})) {
      $filter->{'sub'}->($self);
    } elsif (exists $filter->{'except'} && !contains($action, $filter->{'except'})) {
      $filter->{'sub'}->($self);
    } elsif (!exists $filter->{'only'} && !exists $filter->{'except'}) {
      $filter->{'sub'}->($self);
    }

    last if $self->rendered();
  }
}

1;
