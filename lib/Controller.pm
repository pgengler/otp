package Controller;

use strict;

use CGI;
use List::MoreUtils qw/ first_index /;

use Util qw/ :all /;

use base 'Exporter';

our @EXPORT = qw/
  before_filter prepend_before_filter
/;

our $_before_filters = { };

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

  $self->_render_html($action, $vars);

  $self->{'_rendered'} = 1;
}

sub rendered()
{
  my $self = shift;

  return $self->{'_rendered'};
}

sub _render_html()
{
  my $self = shift;
  my ($action, $vars) = @_;

  require CGI;
  require Template::HTML;

  my $template = new Template::HTML(sprintf('%s/%s.html.tt2', $self->{'_name'}, $action));

  print CGI::header({ 'charset' => 'utf-8' });
  print $template->process($vars);
}

sub before_filter($;%)
{
	my ($filter_sub, %options) = @_;

  my @caller = caller();
  my $controller_name = controller_name_from_package($caller[0]);

  my $filter_info = _filter_info($filter_sub, %options);

  if (not exists $_before_filters->{ $controller_name }) {
    $_before_filters->{ $controller_name } = [ ];
  }

  push @{ $_before_filters->{ $controller_name } }, $filter_info;
}

sub prepend_before_filter()
{
	my ($filter_sub, %options) = @_;

  my @caller = caller();
  my $controller_name = controller_name_from_package($caller[0]);

  my $filter_info = _filter_info($filter_sub, %options);

  if (not exists $_before_filters->{ $controller_name }) {
    $_before_filters->{ $controller_name } = [ ];
  }

  unshift @{ $_before_filters->{ $controller_name } }, $filter_info;
}

sub _filter_info($;%)
{
	my ($filter_sub, %options) = @_;

  my $filter_info = {
    'sub' => $filter_sub,
  };

  # 'only' takes precendece over 'except' if both are specified
  if ($options{'only'} && ref($options{'only'}) eq 'ARRAY') {
    $filter_info->{'only'} = $options{'only'};
  } elsif ($options{'except'} && ref($options{'except'}) eq 'ARRAY') {
    $filter_info->{'except'} = $options{'except'};
  }

  return $filter_info;
}


sub _run_filters()
{
  my $self = shift;
  my ($action) = @_;

  my $filters = $_before_filters->{ controller_name_from_package(ref($self)) } || [ ];

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
