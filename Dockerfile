FROM ubuntu:trusty
MAINTAINER David Personette <dperson@dperson.com>

# Install lighttpd and smokeping
RUN apt-get update && \
    apt-get install -qqy --no-install-recommends smokeping ssmtp dnsutils \
                fonts-dejavu-core echoping curl lighttpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure
RUN mkdir -p /var/lib/smokeping /var/run/smokeping && \
    chown -Rh smokeping:www-data /var/cache/smokeping /var/lib/smokeping \
                /var/run/smokeping && \
    chmod -R g+ws /var/cache/smokeping /var/lib/smokeping /var/run/smokeping && \
    lighttpd-enable-mod cgi && \
    ln -s /usr/share/smokeping/www /var/www/smokeping

VOLUME ["/etc/smokeping", "/etc/ssmtp", "/var/lib/smokeping"]

EXPOSE 80

CMD service smokeping start && \
    lighttpd -D
