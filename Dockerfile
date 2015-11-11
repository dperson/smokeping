FROM debian:jessie
MAINTAINER David Personette <dperson@dperson.com>

# Install lighttpd and smokeping
RUN export DEBIAN_FRONTEND='noninteractive' && \
    apt-get update -qq && \
    apt-get install -qqy --no-install-recommends smokeping ssmtp dnsutils \
                fonts-dejavu-core echoping curl lighttpd \
                $(apt-get -s dist-upgrade|awk '/^Inst.*ecurity/ {print $2}') &&\
    apt-get clean
RUN apt-get install -qqy etckeeper && \
    /bin/sed -i -e 's/#AVOID_DAILY_AUTOCOMMITS=1/AVOID_DAILY_AUTOCOMMITS=1/g' /etc/etckeeper/etckeeper.conf && \
    /bin/sed -i -e 's/#AVOID_COMMIT_BEFORE_INSTALL=1/AVOID_COMMIT_BEFORE_INSTALL=1/g' /etc/etckeeper/etckeeper.conf
RUN lighttpd-enable-mod cgi && \
    lighttpd-enable-mod fastcgi && \
    [ -d /var/cache/smokeping ] || mkdir -p /var/cache/smokeping && \
    [ -d /var/lib/smokeping ] || mkdir -p /var/lib/smokeping && \
    [ -d /run/smokeping ] || mkdir -p /run/smokeping && \
    chown -Rh smokeping:www-data /var/cache/smokeping /var/lib/smokeping \
                /run/smokeping && \
    chmod -R g+ws /var/cache/smokeping /var/lib/smokeping /run/smokeping &&\
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    ln -s /usr/share/smokeping/www /var/www/smokeping && \
    ln -s /usr/lib/cgi-bin /var/www/ && \
    ln -s /usr/lib/cgi-bin/smokeping.cgi /var/www/smokeping/

COPY conf/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf
COPY conf/lighttpd/10-cgi.conf /etc/lighttpd/conf-available/10-cgi.conf
COPY conf/lighttpd/10-fastcgi.conf /etc/lighttpd/conf-available/10-fastcgi.conf
COPY conf/lighttpd/15-fastcgi-php.conf /etc/lighttpd/conf-available/15-fastcgi-php.conf
COPY conf/smokeping/config.d/* /etc/smokeping/config.d/

COPY conf/smokeping/smokeping.fcgi /usr/share/smokeping/www/smokeping.fcgi

COPY smokeping.sh /usr/bin/

VOLUME ["/run", "/tmp", "/var/cache", "/var/lib", "/var/log", "/var/tmp", \
            "/etc/smokeping", "/etc/ssmtp"]

EXPOSE 80

ENTRYPOINT ["smokeping.sh"]
