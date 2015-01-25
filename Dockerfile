FROM ubuntu:trusty
MAINTAINER David Personette <dperson@dperson.com>

ENV DEBIAN_FRONTEND noninteractive

# Install lighttpd and smokeping
RUN apt-get update -qq && \
    apt-get install -qqy --no-install-recommends smokeping ssmtp dnsutils \
                fonts-dejavu-core echoping curl lighttpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    lighttpd-enable-mod cgi && \
    lighttpd-enable-mod fastcgi && \
    ln -s /usr/share/smokeping/www /var/www/smokeping && \
    ln -s /usr/lib/cgi-bin /var/www/ && \
    ln -s /usr/lib/cgi-bin/smokeping.cgi /var/www/smokeping/

COPY 10-cgi.conf /etc/lighttpd/conf-available/
COPY smokeping.sh /usr/bin/

VOLUME ["/etc/smokeping", "/etc/ssmtp", "/var/lib/smokeping"]

EXPOSE 80

ENTRYPOINT ["smokeping.sh"]
