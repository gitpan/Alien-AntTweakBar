use 5.006;
use strict;
use warnings;

use Alien::Base::ModuleBuild;
use Cwd;
use Config;
use File::Spec::Functions;

my $perlbin = $Config{perlpath};
my $patch_location = catfile("..", "..", "inc", "makefile-so-linking.patch");

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

#my $pkg_generator = getcwd . "/inc/" . "pkg-config-generate.pl";

my $builder = Alien::Base::ModuleBuild->new(
    module_name         => 'Alien::AntTweakBar',
    license             => 'perl',
    dist_author         => q{basiliscos <dmol@gmx.com>},
    dist_version_from   => 'lib/Alien/AntTweakBar.pm',
    configure_requires => {
        'Alien::Base' => 0,
        'Module::Build' => 0.38,
    },
    requires => {
        'perl' => 5.006,
        'Alien::Base' => 0,
    },
    test_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'Alien-AntTweakBar-*' ],

    alien_name => 'libanttweakbar',
    alien_repository => {
        protocol => 'http',
        host => 'downloads.sourceforge.net',
        location => '/project/anttweakbar/',
        exact_filename => 'AntTweakBar_116.zip',
    },

    ## For development, to save the download time,
    ## download the package once and put it in an 'inc' directory.
    # alien_repository => {
    #     protocol => 'local',
    #     location => 'inc',
    #     exact_filename => 'AntTweakBar_116.zip',
    #     exact_version  => '1.16',
    # },
    alien_build_commands => [
#        $perlbin." $pkg_generator %p/libanttweakbar.pc %s $version",
        "patch -p1 < $patch_location",
        'make -C "%p/src"',
    ],
    alien_install_commands => [
        'install -D %p/lib/libanttweakbar.so %s/lib/libanttweakbar.so',
        'install -D %p/include/AntTweakBar.h %s/include/AntTweakBar.h',
#        'install -D %p/libanttweakbar.pc %s/lib/pkgconfig/libanttweakbar.pc',
        $perlbin.' -e "use Alien::AntTweakBar; print Alien::AntTweakBar::VERSION"',
    ],
);

$builder->create_build_script;
