package Alien::AntTweakBar;

use 5.008;
use strict;
use warnings;

use Carp;
use Alien::AntTweakBar::ConfigData;
use File::ShareDir qw(dist_dir);
use File::Spec::Functions qw(catdir);

=head1 NAME

Alien::AntTweakBar - perl5 alien library for AntTweakBar

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02_09';

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

1;
