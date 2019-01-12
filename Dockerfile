FROM debian:stretch
MAINTAINER David Personette <dperson@gmail.com>

# Install lighttpd and smokeping
RUN export DEBIAN_FRONTEND='noninteractive' && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends ca-certificates curl dnsutils \
                echoping fonts-dejavu-core lighttpd procps smokeping ssmtp \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    apt-get clean && \
    echo '+ EchoPingHttp\n\nbinary = /usr/bin/echoping\n' \
                >>/etc/smokeping/config.d/Probes && \
    echo '+ EchoPingHttps\n\nbinary = /usr/bin/echoping\n' \
                >>/etc/smokeping/config.d/Probes && \
    sed -i '/^syslogfacility/s/^/#/' /etc/smokeping/config.d/General && \
    sed -i 's/the \(SmokePing website\) of xxx Company/our \1/' \
                /etc/smokeping/config.d/General && \
    conf=/etc/lighttpd/lighttpd.conf dir=/etc/lighttpd/conf-available \
                header=setenv.add-response-header && \
    sed -i '/server.errorlog/s|^|#|' $conf && \
    sed -i '/server.document-root/s|/html||' $conf && \
    sed -i '/server.modules = (/a \t"mod_setenv",' $conf && \
    echo "\\n$header"' += ( "X-XSS-Protection" => "1; mode=block" )' >>$conf &&\
    echo "$header"' += ( "X-Content-Type-Options" => "nosniff" )' >>$conf && \
    echo "$header"' += ( "X-Robots-Tag" => "none" )' >>$conf&& \
    echo "$header"' += ( "X-Frame-Options" => "SAMEORIGIN" )' >>$conf && \
    echo '\n$HTTP["url"] =~ "^/smokeping($|/)" {' >>$conf && \
    echo '\tdir-listing.activate = "disable"\n}' >>$conf && \
    echo '\n# redirect to the right Smokeping URI' >>$conf && \
    echo 'url.redirect  = ("^/$" => "/smokeping/smokeping.cgi",' >>$conf && \
    echo '\t\t\t"^/smokeping/?$" => "/smokeping/smokeping.cgi")' >>$conf && \
    sed -i 's|var/log/lighttpd/access.log|tmp/log|' $dir/10-accesslog.conf && \
    sed -i '/^#cgi\.assign/,$s/^#//; /"\.pl"/i\ \t".cgi"  => "/usr/bin/perl",' \
                $dir/10-cgi.conf && \
    echo '\nfastcgi.server += ( ".cgi" =>\n\t((' >>$dir/10-fastcgi.conf && \
    sed -i -e '/CHILDREN/s/[0-9][0-9]*/16/' \
                -e '/max-procs/a\ \t\t"idle-timeout" => 20,' \
                $dir/15-fastcgi-php.conf && \
    grep -q 'allow-x-send-file' $dir/15-fastcgi-php.conf || { \
        sed -i '/idle-timeout/a\ \t\t"allow-x-send-file" => "enable",' \
                    $dir/15-fastcgi-php.conf && \
        sed -i '/"bin-environment"/a\ \t\t\t"MOD_X_SENDFILE2_ENABLED" => "1",' \
                    $dir/15-fastcgi-php.conf; } && \
    echo '\t\t"socket" => "/tmp/perl.socket" + var.PID,' \
                >>$dir/10-fastcgi.conf && \
    echo '\t\t"bin-path" => "/usr/lib/cgi-bin/smokeping.cgi",'\
                >>$dir/10-fastcgi.conf && \
    echo '\t\t"docroot" => "/var/www",' >>$dir/10-fastcgi.conf && \
    echo '\t\t"check-local"     => "disable",\n\t))\n)' \
                >>$dir/10-fastcgi.conf && \
    unset conf dir header && \
    lighttpd-enable-mod cgi && \
    lighttpd-enable-mod fastcgi && \
    [[ -d /var/cache/smokeping ]] || mkdir -p /var/cache/smokeping && \
    [[ -d /var/lib/smokeping ]] || mkdir -p /var/lib/smokeping && \
    [[ -d /run/smokeping ]] || mkdir -p /run/smokeping && \
    [[ -d /var/www/cgi-bin ]] || rmdir /var/www/cgi-bin && \
    ln -s /usr/share/smokeping/www /var/www/smokeping && \
    ln -s /usr/lib/cgi-bin /var/www/ && \
    ln -s /usr/lib/cgi-bin/smokeping.cgi /var/www/smokeping/ && \
    chown -Rh smokeping:www-data /var/cache/smokeping /var/lib/smokeping \
                /run/smokeping && \
    chmod -R g+ws /var/cache/smokeping /var/lib/smokeping /run/smokeping && \
    chmod u+s /usr/bin/fping && \
    rm -rf /var/lib/apt/lists/* /tmp/*
COPY smokeping.sh /usr/bin/

VOLUME ["/etc/smokeping", "/etc/ssmtp", "/var/lib/smokeping", \
            "/var/cache/smokeping"]

EXPOSE 80

ENTRYPOINT ["smokeping.sh"]