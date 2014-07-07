package Alien::AntTweakBar;

use 5.008;
use strict;
use warnings;

use Carp;
use Alien::AntTweakBar::ConfigData;
use DynaLoader ();
use File::ShareDir qw(dist_dir);
use File::Spec::Functions qw(catdir catfile rel2abs);
use Text::ParseWords qw/shellwords/;

=head1 NAME

Alien::AntTweakBar - perl5 alien library for AntTweakBar

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02_06';

sub config
{
  my ($package, $param) = @_;
  return unless ($param =~ /[a-z0-9_]*/i);
  my $subdir = Alien::AntTweakBar::ConfigData->config('share_subdir');
  unless ($subdir) {
      # we are using tidyp already installed librarry on your system not compiled one
      # therefore no additinal magic needed
      return Alien::AntTweakBar::ConfigData->config('config')->{$param};
  }
  my $share_dir = dist_dir('Alien-AntTweakBar');
  my $real_prefix = catdir($share_dir, $subdir);
  my $val = Alien::AntTweakBar::ConfigData->config('config')->{$param};
  return unless $val;
  $val =~ s/\@PrEfIx\@/$real_prefix/g; # handle @PrEfIx@ replacement
  return $val;
}

sub import {
  my $class = shift;

  # return if $class->install_type('system');

  # get a reference to %Alien::MyLibrary::AlienLoaded
  # which contains names of already loaded libraries
  # this logic may be replaced by investigating the DynaLoader arrays
  my $loaded = do {
    no strict 'refs';
    no warnings 'once';
    \%{ $class . "::AlienLoaded" };
  };

  my @libs = shellwords( $class->config('libs') );

  my @L = grep { s/^-L// } @libs;
  my @l = grep { /^-l/ } @libs;

  push @DynaLoader::dl_library_path, @L;

  my @libpaths;
  foreach my $l (@l) {
    next if $loaded->{$l};

    my $path = DynaLoader::dl_findfile( $l );
    unless ($path) {
      carp "Could not resolve $l";
      next;
    }

    push @libpaths, $path;
    $loaded->{$l} = $path;
  }

  push @DynaLoader::dl_resolve_using, @libpaths;

  my @librefs = map { DynaLoader::dl_load_file( $_, 0x01 ) } @libpaths;
  push @DynaLoader::dl_librefs, @librefs;

}

1;
