package My::Builder;

use strict;
use warnings;

use base 'Alien::Base::ModuleBuild';

sub do_commands_hook {
    my ($self, $command) = @_;
    print "default (empty) hook before doing $command\n";
}

sub alien_do_commands {
    my ($self, $command) = @_;
    $self->do_commands_hook($command);
    return $self->SUPER::alien_do_commands($command);
}

1;
