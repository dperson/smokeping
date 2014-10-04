FROM ubuntu:trusty
MAINTAINER David Personette <dperson@dperson.com>

# Install lighttpd and smokeping
RUN apt-get update && \
    apt-get install -qqy --no-install-recommends smokeping ssmtp dnsutils \
                libplack-app-proxy-perl libcgi-emulate-psgi-perl \
                libfcgi-procmanager-perl fonts-dejavu-core echoping && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure
COPY smokeping.psgi /usr/lib/cgi-bin/
RUN mkdir -p /var/lib/smokeping /var/run/smokeping && \
    chown -Rh smokeping:www-data /var/lib/smokeping /var/run/smokeping && \
    chmod -R g+ws /var/lib/smokeping

VOLUME ["/etc/smokeping", "/etc/ssmtp", "/var/lib/smokeping"]

EXPOSE 5000

CMD service smokeping start && \
    plackup -p 5000 /usr/lib/cgi-bin/smokeping.psgi
