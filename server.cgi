#!/usr/bin/perl

use strict;

use CGI qw/ :standard /;
use Cwd;

use lib (cwd.'/modules/');

use Logger qw/ :levels /;
use Template::HTML;

use constant {
  DEFAULT_CONTROLLER => 'TestController',
  DEFAULT_ACTION     => 'index',
};

##############

my $logger = new Logger('server', INFO);

my $path_info = get_path_info();
$logger->debug("Path info is '%s'", join('|', @$path_info));

my $controller_name = find_controller($path_info);
$logger->debug("Controller name is '%s'", $controller_name);

my $method_name = find_method($path_info);
$logger->debug("Method name is '%s'", $method_name);

my @parameters = splice(@$path_info, 2);

execute($controller_name, $method_name, @parameters);

##############

sub execute()
{
  my ($controller_name, $method_name, @arguments) = @_;

  my $controller_base_name = lc($controller_name);
  $controller_base_name =~ s/controller$//;

  my $controller;
  my $vars;

  eval {
    # Load controller module
    local @INC = @INC;
    push @INC, cwd.'/controllers/';

    require $controller_name.'.pm';

    # Instantiate controller
    $controller = new $controller_name;

    # Run filters
    $controller->_run_filters($method_name);

    # Call action
    unless ($controller->rendered()) {
      $vars = $controller->$method_name(@arguments);
    }
  };
  if ($@) {
    my $exception = $@;

    $logger->fatal($exception);
    exit(1);
  }

  unless ($controller->rendered()) {
    # Load template with same name as controller/action
    my $template = new Template::HTML($controller_base_name . '/' . $method_name . '.html.tt2');
    print header({ 'charset' => 'utf-8' });
    print $template->process($vars);
  }
}

sub get_path_info()
{
  if ($ENV{'PATH_INFO'}) {
    my @path_components = split(/\//, $ENV{'PATH_INFO'});
    shift @path_components;
    return [ @path_components ];
  }
  return [ ];
}

# for now, just do the simple thing and treat the first component of the path info as the controller name
sub find_controller($)
{
  my ($path_info) = @_;

  if (scalar @$path_info > 0) {
    return ucfirst($path_info->[0]).'Controller';
  }

  return DEFAULT_CONTROLLER;
}

# for now, just do the simple thing and treat the second component of the path info as the method name
sub find_method($)
{
  my ($path_info) = @_;

  if (scalar @$path_info > 1) {
    return $path_info->[1];
  }

  return DEFAULT_ACTION;
}

