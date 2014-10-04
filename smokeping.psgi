#!/usr/bin/perl
use strict;
use warnings;

use Plack::App::Directory;
use Plack::Builder;
use CGI::Emulate::PSGI;

my $app = CGI::Emulate::PSGI->handler(sub {
    use CGI;
    use Smokeping;
    CGI::initialize_globals();
    my $cfg = "/etc/smokeping/config";
    my $q = CGI->new;
    Smokeping::cgi($cfg, $q);
});

my $fileapp = Plack::App::Directory->new
    ({ 'root' => '/usr/share/smokeping/www' })->to_app;

builder {
    mount "/"           => $app;
    mount "/smokeping/" => $fileapp;
};
