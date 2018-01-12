#!/usr/bin/env perl

use strict;
use warnings 'FATAL';

use Path::Class 'dir';
use Test::Exception;
use Test::More tests => 6;

use lib dir(__FILE__)->absolute->parent->parent->subdir('lib')->stringify;

my $pkg = 'MyConfig::CLI';
use_ok($pkg) or die;

subtest 'failures' => sub{
    plan tests => 3;

    throws_ok(sub{ $pkg->run('list'); }, qr/\[ERROR\] No config loaded/, 'fails w/o config loaded');
    $ENV{REFIMP_CONFIG_FILE} = 'blah.yml';
    throws_ok(sub{ $pkg->run('list'); }, qr/\[ERROR\] No config loaded/, 'fails w/ non existing config file');
    throws_ok(sub{ $pkg->run; }, qr/\[ERROR\] No function given/, 'fails w/o ARGV');

};

subtest 'help' => sub{
    plan tests => 2;

    run_ok([qw/ help /], qr/^\[USAGE\] myconfig list/);
};

subtest 'get' => sub{
    plan tests => 3;

    throws_ok(sub{ $pkg->run('key'); }, qr/\[ERROR\] Unknown function: key/, 'fails w/ invalid function ARGV');
    MyConfig::set('key', 'value');
    run_ok([qw/ get key /], qr/value/); 
    MyConfig::unset('key');

};

subtest 'ds' => sub{
    plan tests => 2;

    MyConfig::set('ds_testdb_server', 'server');
    run_ok([qw/ ds testdb /], qr/server$/); 

};

subtest 'list' => sub{
    plan tests => 2;

    run_ok([qw/ list /], qr/^\-\-\-\n/); 

};

done_testing();

###

sub run_ok {
    my ($params, $expected_output) = @_;
    my $output;
    open local( *STDOUT), '>', \$output or die $!;
    my $rv = $pkg->run(@$params);
    is($rv, 0, "RUN ".join(' ', @$params));
    like($output, $expected_output, "OUPUT ".join(' ', @$params));
}
use lib dir(__FILE__)->absolute->parent->parent->subdir('lib')->stringify;
