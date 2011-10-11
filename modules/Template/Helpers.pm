package Template::Helpers;

use strict;

use base 'Exporter';

our @EXPORT_OK = qw/
  link_to
/;

sub link_to()
{
  my ($path, $text) = @_;
  $text ||= $path;

  my $fullURL = '/otp/server.cgi/' . $path;

  return sprintf('<a href="%s">%s</a>', $fullURL, $text);
}

sub _refs()
{
  return {
    map { $_ => \&{ $_ } } @EXPORT_OK
  };
}
