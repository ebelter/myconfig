#!/usr/bin/env perl

use strict;
use warnings 'FATAL';

use Path::Class 'dir';
use Test::Exception;
use Test::More tests => 6;

use lib dir(__FILE__)->absolute->parent->parent->subdir('lib')->stringify;

my %test = ( class => 'MyConfig' );
use_ok($test{class}) or die;

subtest 'load_config_from_file' =>  sub{
    plan tests => 4;

    my $invalid_yml = 'config.invalid.yml';
    throws_ok(sub{ MyConfig::load_config_from_file($invalid_yml); }, qr/YAML Error/, 'load_config fails w/ invalid yml');

    ok(MyConfig::load_config_from_file('config.yml'), 'load_config_file');

    ok(MyConfig::is_loaded(), 'config is loaded');
    is(MyConfig::config_loaded_from(), 'config.yml', 'config_file_loaded');

};

subtest 'get' => sub{
    plan tests => 3;

    throws_ok(sub{ MyConfig::get(); }, qr/No key to get config\!/, 'get without key');
    throws_ok(sub{ MyConfig::get('nada'); }, qr/Invalid key to get config\! nada/, 'get with invalid key');
    is(MyConfig::get('key'), 'value', 'get');

};

subtest 'set' => sub{
    plan tests => 6;

    throws_ok(sub{ MyConfig::set(); }, qr/No key to set config\!/, 'set with no params');
    throws_ok(sub{ MyConfig::set('key'); }, qr/No value to set config\!/, 'set without value');

    lives_ok(sub{ MyConfig::set('key', 'new+value'); }, 'set');
    is(MyConfig::get('key'), 'new+value', 'get the new value');

    lives_ok(sub{ MyConfig::set('nada', 'new+key!'); }, 'set with new key');
    is(MyConfig::get('nada'), 'new+key!', 'get the new key value');

};

subtest 'to_string' => sub{
    plan tests => 1;

    my $config = MyConfig::to_string();
    my $expected_config = join("\n", "---", "key: new+value", "nada: new+key!", "");
    is($config, $expected_config, 'got config');

};

subtest 'unset' => sub{
    plan tests => 3;

    throws_ok(sub{ MyConfig::unset(); }, qr/No key to unset config\!/, 'set with no params');
    lives_ok(sub{ MyConfig::unset('nada'); }, 'unset nada');
    throws_ok(sub{ MyConfig::get('nada'); }, qr/Invalid key to get config\! nada/, 'get with invalid key');

};

done_testing();
