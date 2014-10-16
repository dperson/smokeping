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

## Hosting a Smokeping instance on port 8000

    sudo docker run --name smokeping -p 8000:80 -d dperson/smokeping

## Configuration

    sudo docker run -it --rm dperson/smokeping -h

    Usage: smokeping.sh [-opt] [command]
    Options (fields in '[]' are optional, '<>' are required):
        -h          This help
        -g "<user;pass>" Configure ssmtp so that email alerts can be sent
                    required arg: "<user>" - your gmail username
                    required arg: "<pass>" - your gmail password of app password
                    These are only set in your docker container
        -e "<email>" Configure email address for owner of smokeping
                    required arg: "<email>" - your email address
        -o "<name>" Configure name of the owner of smokeping
                    required arg: "<name>" - your name
        -t "<site;name;target>[;alert]" Configure smokeping targets
                    required arg: "<site>" - name for site of tests
                    required arg: "<name>" - name for check
                    required arg: "<target>" - hostname or IP to check
                    possible arg: "[alert]" - send emails on failures
        -T ""       Configure timezone
                    possible arg: "[timezone]" - zoneinfo timezone for container
        -w          Wipe the targets clean

    The 'command' (if provided and valid) will be run instead of nginx

### Start smokeping, and configure sSMTP to forward alerts:

    sudo docker run --rm -p 80:80 dperson/smokeping -g "exampleuser;examplepass"

### Start smokeping, and configure owners email address:

    sudo docker run --rm -p 80:80 dperson/smokeping -e "exampleuser@gmail.com"

### Start smokeping, and configure owners name:

    sudo docker run --rm -p 80:80 dperson/smokeping -o "Example User"

### Start smokeping, and timezone:

    sudo docker run --rm -p 80:80 dperson/smokeping -T EST5EDT

### Start smokeping, clear targets, setup a new one to the first hop from ISP:

    IP=$(traceroute -n google.com |
                egrep -v ' (10|172\.(1[6-9]|2[0-9]|3[01])|192.168)\.' |
                awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+.*ms/ {print $2; exit}')
    sudo docker run --rm -p 80:80 dperson/smokeping -w -t "ISP;NextHop;$IP"

## Complex configuration

[Example configs](http://oss.oetiker.ch/smokeping/doc/smokeping_examples.en.html)

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
