FROM ubuntu:trusty
MAINTAINER David Personette <dperson@dperson.com>

ENV DEBIAN_FRONTEND noninteractive

# Install lighttpd and smokeping
RUN apt-get update -qq && \
    apt-get install -qqy --no-install-recommends smokeping ssmtp dnsutils \
                fonts-dejavu-core echoping curl lighttpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    ln -sf /dev/stdout /var/log/lighttpd/access.log && \
    ln -sf /dev/stderr /var/log/lighttpd/error.log
# Forward request and error logs to docker log collector

# Configure
COPY 10-cgi.conf /etc/lighttpd/conf-available/
COPY smokeping.sh /usr/bin/
RUN lighttpd-enable-mod cgi && \
    lighttpd-enable-mod fastcgi && \
    ln -s /usr/share/smokeping/www /var/www/smokeping && \
    ln -s /usr/lib/cgi-bin /var/www/ && \
    ln -s /usr/lib/cgi-bin/smokeping.cgi /var/www/smokeping/

VOLUME ["/etc/smokeping", "/etc/ssmtp", "/var/lib/smokeping"]

EXPOSE 80

ENTRYPOINT ["smokeping.sh"]
