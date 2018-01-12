#!/usr/bin/env perl

use strict;
use warnings 'FATAL';

use Module::Build;

my $build = Module::Build->new(
    module_name => 'MyConfig',
    license => 'perl',
    dist_author => 'Eddie Belter <ebelter@cpan.org>',
    dist_abstract => 'Basic Application Config with Command Line Interface',
    dist_version => '0.01',
    test_requires => {
        'Path::Class' => 1,
        'Test::Exception' => 1,
        'Test::More' => 1,
    },
    build_requires => {
        'Module::Build' => 0,
    },
);
$build->create_build_script;
