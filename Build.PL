use strict;
use warnings;

use lib "inc";

#### we need the platform-specific module
my %platforms =(
       # Unix = default, thus not listing all UNIX like systems
       MSWin32 => 'Windows',
);
my $package = 'My::Builder::' . ($platforms{$^O} || 'Unix');
print "Gonna use '$package' class ...\n";
eval "require $package" or die "Require '$package' failed: $@\n";

my $builder = $package->new(
    module_name         => 'Alien::AntTweakBar',
    license             => 'perl',
    dist_author         => q{basiliscos <dmol@gmx.com>},
    dist_version_from   => 'lib/Alien/AntTweakBar.pm',
    configure_requires => {
        'Alien::Base'           => 0,
        'File::Basename'        => 0,
        'File::Copy'            => 0,
        'File::Spec::Functions' => 0,
        'Module::Build'         => 0.38,
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
);

$builder->create_build_script;
