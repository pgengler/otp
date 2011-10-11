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

my $pathInfo = getPathInfo();
$logger->debug("Path info is '%s'", join('|', @$pathInfo));

my $controllerName = findController($pathInfo);
$logger->debug("Controller name is '%s'", $controllerName);

my $methodName = findMethod($pathInfo);
$logger->debug("Method name is '%s'", $methodName);

my @parameters = splice(@$pathInfo, 2);

execute($controllerName, $methodName, @parameters);

##############

sub execute()
{
  my ($controllerName, $methodName, @arguments) = @_;

  my $controllerBaseName = lc($controllerName);
  $controllerBaseName =~ s/controller$//;

  my $controller;
  my $vars;

  eval {
    # Load controller module
    local @INC = @INC;
    push @INC, cwd.'/controllers/';

    require $controllerName.'.pm';

    # Instantiate controller
    $controller = new $controllerName;

    # Run filters
    $controller->_runFilters($methodName);

    # Call action
    unless ($controller->rendered()) {
      $vars = $controller->$methodName(@arguments);
    }
  };
  if ($@) {
    my $exception = $@;

    $logger->fatal($exception);
    exit(1);
  }

  unless ($controller->rendered()) {
    # Load template with same name as controller/action
    my $template = new Template::HTML($controllerBaseName . '/' . $methodName . '.html.tt2');
    print header({ 'charset' => 'utf-8' });
    print $template->process($vars);
  }
}

sub getPathInfo()
{
  if ($ENV{'PATH_INFO'}) {
    my @pathComponents = split(/\//, $ENV{'PATH_INFO'});
    shift @pathComponents;
    return [ @pathComponents ];
  }
  return [ ];
}

# for now, just do the simple thing and treat the first component of the path info as the controller name
sub findController($)
{
  my ($pathInfo) = @_;

  if (scalar @$pathInfo > 0) {
    return ucfirst($pathInfo->[0]).'Controller';
  }

  return DEFAULT_CONTROLLER;
}

# for now, just do the simple thing and treat the second component of the path info as the method name
sub findMethod($)
{
  my ($pathInfo) = @_;

  if (scalar @$pathInfo > 1) {
    return $pathInfo->[1];
  }

  return DEFAULT_ACTION;
}

