package MyConfig::CLI;

use strict;
use warnings 'FATAL';

use List::MoreUtils 'any';
use MyConfig;

my %functions_and_usages = (
    get   => "[USAGE] myconfig get \$KEY",
    ds    => "[USAGE] myconfig ds \$DATASOURCE",
    list  => "[USAGE] myconfig list",
);
$functions_and_usages{help} = join("\n", map { $functions_and_usages{$_} } (qw/ list get ds/));

sub run {
    my $class = shift;

    die "[ERROR] No function given!\n$functions_and_usages{help}" if ! @_;

    my $function = shift;
    die "[ERROR] Unknown function: $function" if not any { $function eq $_ } keys %functions_and_usages;
    print "$functions_and_usages{help}\n" and return 0 if $function eq 'help';

    my $self = bless { function => $function }, $class;
    if ( ! MyConfig::is_loaded() ) {
        if ( exists $ENV{REFIMP_CONFIG_FILE} && -s $ENV{REFIMP_CONFIG_FILE} ) {
            MyConfig::load_config_from_file( $ENV{REFIMP_CONFIG_FILE} );
        }
        else {
            die "[ERROR] No config loaded!";
        }
    }
    $self->$function(@_);

    return 0;
}

sub get {
    my ($self, $key) = @_;
    die "[ERROR] Missing key to get config!\n$functions_and_usages{get}\n" if ! defined $key;
    print MyConfig::get($key);
}

sub ds {
    my ($self, $ds) = @_;
    die "[ERROR] Missing datasource to get config!\n$functions_and_usages{get}\n" if ! defined $ds;
    my $server = MyConfig::get('ds_'.$ds.'_server');
    my $login = eval{ MyConfig::get('ds_'.$ds.'_login') };
    my $auth = eval{ MyConfig::get('ds_'.$ds.'_auth') };
    if ( not $login and not $auth ) {
        print "$server\n";
    }
    else {
        printf("%s/%s@%s\n", $login, $auth, $server);
    }
}

sub list {
    my $self = shift;
    print MyConfig::to_string()."\n";
}

1;
