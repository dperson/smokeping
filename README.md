# Smokeping

Smokeping docker image

# What is Smokeping?

SmokePing keeps track of your network latency:

 * Best of breed latency visualisation.
 * Interactive graph explorer.
 * Wide range of latency measurment plugins.
 * Master/Slave System for distributed measurement.
 * Highly configurable alerting system.
 * Live Latency Charts with the most 'interesting' graphs.

[oss.oetiker.ch/smokeping](http://oss.oetiker.ch/smokeping/)

![logo](http://oss.oetiker.ch/smokeping/inc/smokeping-logo.png)

# How to use this image

## Hosting a Smokeping instance with reports on port 8000

    sudo docker run --name smokeping -p 8000:80 -d dperson/smokeping

## Complex configuration

If you wish to adapt the default configuration, use something like the following
to copy it from a running container:

    sudo docker cp smokeping:/etc/smokeping /some/path

You can use the modified configuration with:

    sudo docker run --name smokeping -p 8000:80 -v /some/path:/etc/smokeping:ro\
                -d dperson/smokeping

# User Feedback

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/dperson/smokeping/issues).
