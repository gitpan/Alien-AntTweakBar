package My::Builder::Unix;

use strict;
use warnings;

use Config;
use File::chdir;
use File::Basename;
use File::Copy qw/move cp/;
use File::Path qw/make_path/;
use File::Spec::Functions qw(catdir catfile rel2abs);


use base 'My::Builder';

sub prebuild {
    my $self = shift;
    my $dst = $self->notes('src_dir') . '/Makefile';
    my $src = $self->base_dir . '/inc/Makefile';
    cp($src, $dst) or die("Can't cp $src $dst: $!");
    print STDERR "Original Makefile has been overwritten.\n";
    my $malloc_h_patch = $self->base_dir . '/inc/malloc_stdlib_h.patch';
    local $CWD = $self->notes('src_dir') . '/../';
    system('patch', '-p1', '-i', "$malloc_h_patch") == 0
        or die("Can't apply $malloc_h_patch: $?");
    print STDERR "Patch $malloc_h_patch has been applied.\n";
}

sub build_binaries {
	my $self = shift;
    print STDERR "Running make ...\n";
    {
        local $CWD = rel2abs( $self->notes('src_dir') );
        $self->do_system($self->_get_make) or die "###ERROR### [$?] during make ... ";
    }
    return 1;
}

sub _get_make {
  my ($self) = @_;

  return $Config{make} if $^O =~ /^(cygwin|MSWin32)$/;

  my @try = ($Config{gmake}, 'gmake', 'make', $Config{make});
  my %tested;
  print "Gonna detect GNU make:\n";
  foreach my $name ( @try ) {
    next unless $name;
    next if $tested{$name};
    $tested{$name} = 1;
    print "- testing: '$name'\n";
    if ($self->_is_gnu_make($name)) {
      print "- found: '$name'\n";
      return $name
    }
  }
  print "- fallback to: 'make'\n";
  return 'make';
}

sub _is_gnu_make {
  my ($self, $name) = @_;
  my $devnull = File::Spec->devnull();
  my $ver = `$name --version 2> $devnull`;
  if ($ver =~ /GNU Make/i) {
    return 1;
  }
  return 0;
}

sub preinstall_binaries {
    my ($self, $out) = @_;
    print STDERR "doing local installation ...\n";
    make_path("$out/lib", "$out/include");
    my $src_dir = rel2abs( $self->notes('src_dir') );
    my %intalled_files = (
        "$src_dir/../include/AntTweakBar.h"   => "$out/include/",
        "$src_dir/../lib/libAntTweakBar.a"    => "$out/lib/",
    );
    while (my ($from, $to_dir) = each %intalled_files) {
        my $to = $to_dir . basename($from);
        move($from, $to) or die("can't move $from -> $to: $!");
    }
	return 1;
}

1;
