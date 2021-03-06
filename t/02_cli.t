use strict;
use warnings;
use Test::More;
use Path::Class;
use lib file(__FILE__)->dir->file('lib')->stringify;

use base qw(Test::Class);


use Test::Cinnamon::CLI;

sub _help : Tests {
    my $app = Test::Cinnamon::CLI::cli();
    $app->run('--help');
    is $app->system_error, "Usage: cinnamon [--config=<path>] [--help] <role> <task>\n";
}

sub _no_config : Tests {
    my $app = Test::Cinnamon::CLI::cli();
    $app->run('role', 'task');
    is $app->system_error, "cannot find config file for deploy : config/deploy.pl\nUsage: cinnamon [--config=<path>] [--help] <role> <task>\n";
}

sub _valid : Tests {
    my $app = Test::Cinnamon::CLI::cli();
    $app->dir->touch("config/deploy.pl", <<CONFIG);
use Cinnamon::DSL;
set user => 'app';
role test => 'localhost';
task echo_user => sub {
    print(get 'user');
};
CONFIG
    $app->run('test', 'echo_user');
    is $app->system_output, 'app';
}

sub _change_config_name : Tests {
    my $app = Test::Cinnamon::CLI::cli();
    $app->dir->touch("config/deploy_changed.pl", <<CONFIG);
use Cinnamon::DSL;
set user => 'app';
role test => 'localhost';
task echo_user => sub {
    print(get 'user');
};
CONFIG
    $app->run('--config=config/deploy_changed.pl', 'test', 'echo_user');
    is $app->system_output, 'app';
}

__PACKAGE__->runtests;

1;
