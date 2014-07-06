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
    $self->check_pkg_config;

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
    my ($self, $out, $src) = @_;
    my $src_dir = rel2abs( $self->notes('src_dir') );
    print STDERR "Running make ...\n";
    {
        local $CWD = $src_dir;
        $self->do_system('make') or die "###ERROR### [$?] during make ... ";
    }
    print STDERR "doing local installation ...\n";
    make_path("$out/lib", "$out/include");
    my %intalled_files = (
        "$src_dir/../include/AntTweakBar.h"   => "$out/include/",
        "$src_dir/../lib/libAntTweakBar.so"   => "$out/lib/",
        "$src_dir/../lib/libAntTweakBar.so.1" => "$out/lib/",
    );
    while (my ($from, $to_dir) = each %intalled_files) {
        my $to = $to_dir . basename($from);
        move($from, $to) or die("can't move $from -> $to: $!");
    }
    return 1;
}

sub check_pkg_config {
    my $self = shift;

    my @required_pkg_modules = qw/glu gl sdl/;
    for my $module (@required_pkg_modules) {
        system(qw/pkg-config --exists/, $module);
        if ($? == -1) {
            die("pkg-config failed: $!")
        } elsif ($? & 127) {
            die("pkg-config died with signal: " . ($? & 127));
        } elsif ($? >> 8 != 0) {
            my $available_packages = `pkg-config --list-all`;
            die("pkg-config cannot find the module $module among\n$available_packages");
        }
    }
}

1;
