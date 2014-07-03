package My::Builder::Unix;

use strict;
use warnings;

use Config;
use File::Basename;
use File::Copy "cp";
use File::Spec::Functions;

use base 'My::Builder';

sub new {
    my ($class, %args) = @_;

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

    my $perlbin = $Config{perlpath};
    $args{alien_build_commands} = [
        'make -C "%p/src"',
    ];
    $args{alien_install_commands} = [
        'mkdir -p %s/lib %s/include',
        'cp %p/lib/libAntTweakBar.so %s/lib',
        'cp %p/include/AntTweakBar.h %s/include',
        $perlbin.' -e "use Alien::AntTweakBar; print Alien::AntTweakBar::VERSION"',
    ];
    my $self = $class->SUPER::new(%args);
    return $self;
}

sub do_commands_hook {
    my ($self, $command) = @_;
    if ($command eq 'build') {
        my $dst = $self->config_data('working_directory') . '/src/Makefile';
        my $src= $self->base_dir . '/inc/Makefile';
        cp($src, $dst) or die("Can't cp $src $dst: $!");
        my $malloc_h_patch = $self->base_dir . '/inc/malloc_stdlib_h.patch';
        system('patch', '-p1', '-i', "$malloc_h_patch") == 0
            or die("Can't apply $malloc_h_patch: $?");
    }
}

1;
