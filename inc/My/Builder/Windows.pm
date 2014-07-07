package My::Builder::Windows;

use strict;
use warnings;

use Config;
use File::Basename;
use File::Copy qw/move cp/;
use File::Path qw/make_path/;
use File::Spec::Functions qw(catdir catfile rel2abs);

use base 'My::Builder';

sub preinstall_binaries {
    my ($self, $out) = @_;
    print STDERR "doing local installation ...\n";
    make_path("$out/lib", "$out/include");
    my $src_dir = rel2abs( $self->notes('src_dir') );
	my $dll_name = $Config{archname} =~ /MSWin32-x64/
		? 'AntTweakBar64.dll'
		: 'AntTweakBar.dll';
    my %intalled_files = (
        "$src_dir/../include/AntTweakBar.h"   => "$out/include/",
        "$src_dir/../lib/$dll_name"   => "$out/lib/",
    );
    while (my ($from, $to_dir) = each %intalled_files) {
        my $to = $to_dir . basename($from);
        move($from, $to) or die("can't move $from -> $to: $!");
    }
	return 1;
}


1;
