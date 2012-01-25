#!/usr/bin/perl

#######
## PERL SETUP
#######
use strict;
use warnings;
use lib ('../lib');

#######
## INCLUDES
#######
use Cwd;
use Test::Unit::TestRunner;

#######
## GLOBALS
######
my $testrunner = new Test::Unit::TestRunner();

sub test($);
sub test_dir($);

##############

#######
## MAIN CODE
#######
if (scalar(@ARGV) > 0) {
	# Run specific test(s)
	foreach my $module (@ARGV) {
		test($module);
	}
} else {
	# Run all tests
	test_dir(getcwd() . '/');
}

##############

#######
## Run all tests in a directory
#######
sub test_dir($)
{
	my $dir = shift;

	opendir(DIR, $dir) or die "Can't open directory '$dir': $!";
	my @files = readdir(DIR);
	closedir(DIR);

	# Go through each file
	foreach my $file (@files) {
		# Skip '.' and '..'
		next if ($file eq '.' || $file eq '..');

		# Recursively process directories
		if (-d $dir . $file) {
			test_dir($dir . $file . '/');
			next;
		}

		# Only process Perl modules (.pm files)
		next unless $file =~ /\.pm$/;

		# Only run tests
		next unless $file =~ /Test/;

		# Run tests in module
		test($dir . $file);
	}
}

#######
## Run a single test module
#######
sub test($)
{
	my $file = shift;

	# Remove file extension
	$file =~ s/(.+)\.pm$/$1/;

	# Remove extraneous path information
	my $cwd = getcwd() . '/';
	$file =~ s/^$cwd//;

	# Convert path separators into module separators
	my $module = $file;
	$module =~ s/\//\:\:/g;

	print "----------------------------\n";
	print "TESTING $module\n";
	print "----------------------------\n";
	$testrunner->start($module);
}

