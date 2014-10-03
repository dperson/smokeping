# -*- cperl -*-

use Plack::App::Directory;
use Plack::Builder;
use CGI::Emulate::PSGI;
use CGI::Fast;

use CGI qw();

use warnings;
use strict;

use Smokeping;

my $smokeping = sub {
    CGI::initialize_globals();

    Smokeping::cgi("/etc/smokeping/config",new CGI::Fast);
};

my $fileapp = Plack::App::Directory->new
    ({ 'root' => '/usr/share/smokeping/www' })->to_app;

$smokeping  = CGI::Emulate::PSGI->handler( $smokeping );

builder {
    mount "/"           => $smokeping;
    mount "/smokeping/" => $fileapp;
};
