package Cinnamon::DSL;
use strict;
use warnings;
use parent qw(Exporter);

use Cinnamon::Config;
use Cinnamon::Local;
use Cinnamon::Remote;
use Cinnamon::Logger;

our @EXPORT = qw(
    set
    get
    role
    task

    remote
    run
    sudo
);

sub set ($$) {
    my ($name, $value) = @_;
    Cinnamon::Config::set $name => $value;
}

sub get ($@) {
    my ($name, @args) = @_;
    Cinnamon::Config::get $name, @args;
}

sub role ($$) {
    my ($name, $hosts) = @_;
    Cinnamon::Config::set_role $name => $hosts;
}

sub task ($%) {
    my ($role, $tasks) = @_;

    for my $task (%$tasks) {
        Cinnamon::Config::set_task $role => $task => $tasks->{$task};
    }
}

sub remote (&$) {
    my ($code, $host) = @_;

    local $_ = Cinnamon::Remote->new(
        host => $host,
        user => Cinnamon::Config::user,
    );

    $code->($host);
}

sub run (@) {
    my (@cmd) = @_;
    my ($stdout, $stderr);
    my $host;
    my $result;

    if (ref $_ eq 'Cinnamon::Remote') {
        $host   = $_->host;
        $result = $_->execute(@cmd);
    }
    else {
        $host   = 'localhost';
        $result = Cinnamon::Local->execute(@cmd);
    }

    if ($result->{has_error}) {
        my $message = sprintf "%s: %s", $host, $result->{error}, join(' ', @cmd);
        die $message;
    }
    else {
        my $message = sprintf "[%s] %s: %s",
            $host, join(' ', @cmd), ($result->{stdout} || $result->{stderr});

        log info => $message;
    }
}

sub sudo (@) {
    my (@cmd) = @_;
    run 'sudo', @cmd;
}

!!1;