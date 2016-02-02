[![logo](https://raw.githubusercontent.com/dperson/smokeping/master/logo.png)](http://oss.oetiker.ch/smokeping/)

# Smokeping

Smokeping docker container

# What is Smokeping?

SmokePing keeps track of your network latency:

 * Best of breed latency visualisation.
 * Interactive graph explorer.
 * Wide range of latency measurment plugins.
 * Master/Slave System for distributed measurement.
 * Highly configurable alerting system.
 * Live Latency Charts with the most 'interesting' graphs.

# How to use this image

When started the smokeping web inteface will listen on port 80 in the container
at the '/smokeping/smokeping.cgi' URI.

## Hosting a Smokeping instance on port 8000

    sudo docker run -it --name smokeping -p 8000:80 -d dperson/smokeping

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
                                Targets can also be http:// or https:// URLs
                    possible arg: "[alert]" - send emails on failures (any val)
        -T ""       Configure timezone
                    possible arg: "[timezone]" - zoneinfo timezone for container
        -w          Wipe the targets clean

    The 'command' (if provided and valid) will be run instead of smokeping

ENVIRONMENT VARIABLES (only available with `docker run`)

 * `SPUSER` - If set use named user instead of 'smokeping' (for example root)
 * `WIPE` - If set will wipe all targets
 * `SSMTP_GMAIL` As above configure ssmtp for gmail, set to `user;pass`
 * `EMAIL` - As above, your email address as the owner `bob@example.net`
 * `OWNER` - As above, your name as the owner `Bob Hope`
 * `TARGET` - As above a target to check, set to `site;name;target[;alert]`
 * `TZ` - As above, configure the zoneinfo timezone, IE `EST5EDT`
 * `USERID` - Set the UID for the app user
 * `GROUPID` - Set the GID for the app user
 * `DEBUG` - Run smokeping in debug mode

## Examples

Any of the commands can be run at creation with `docker run` or later with
`docker exec -it smokeping.sh` (as of version 1.3 of docker).

### Setting the Timezone

    sudo docker run -it -p 8000:80 -d dperson/smokeping -T EST5EDT

OR using `environment variables`

    sudo docker run -it -p 8000:80 -e TZ=EST5EDT -d dperson/smokeping

Will get you the same settings as

    sudo docker run -it --name smokeping -p 8000:80 -d dperson/smokeping
    sudo docker exec -it smokeping smokeping.sh -T EST5EDT \
                ls -AlF /etc/localtime
    sudo docker restart smokeping

### Start smokeping, clear targets, setup a new one to the first hop from ISP:

    IP=$(traceroute -n google.com |
                egrep -v ' (10|172\.(1[6-9]|2[0-9]|3[01])|192.168)\.' |
                awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+.*ms/ {print $2; exit}')
    sudo docker run -it -p 8000:80 -d dperson/smokeping -w -t "ISP;NextHop;$IP"

OR

    IP=$(traceroute -n google.com |
                egrep -v ' (10|172\.(1[6-9]|2[0-9]|3[01])|192.168)\.' |
                awk '/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+.*ms/ {print $2; exit}')
    sudo docker run -it -p 8000:80 -e WIPE=y -e TARGET="ISP;NextHop;$IP" \
                -d dperson/smokeping

### To add additional targets (replace values in <> with your own):

    sudo docker exec -it <name_of_instance> smokeping.sh -t "<site;name;target>"

IE

    sudo docker exec -it stunned_newton smokeping.sh \
                -t "home;router;bob.dyndns.org"

### Start smokeping, and configure sSMTP to forward alerts:

    sudo docker run -it -p 8000:80 -d dperson/smokeping \
                -g "sampleuser;samplepass"

OR

    sudo docker run -it -p 8000:80 -e SSMTP_GMAIL="sampleuser;samplepass" \
                -d dperson/smokeping

### Start smokeping, and configure owners email address:

    sudo docker run -it -p 8000:80 -d dperson/smokeping \
                -e "sampleuser@gmail.com"

OR

    sudo docker run -it -p 8000:80 -e EMAIL="sampleuser@gmail.com" \
                -d dperson/smokeping

### Start smokeping, and configure owners name:

    sudo docker run -it -p 8000:80 -d dperson/smokeping -o "Sample User"

OR

    sudo docker run -it -p 8000:80 -e OWNER="Sample User" -d dperson/smokeping

## Complex configuration

[Example configs](http://oss.oetiker.ch/smokeping/doc/smokeping_examples.en.html)

If you wish to adapt the default configuration, use something like the following
to copy it from a running container:

    sudo docker cp smokeping:/etc/smokeping /some/path

You can use the modified configuration with:

    sudo docker run -it --name smokeping -p 8000:80 \
                -v /some/path:/etc/smokeping:ro -d dperson/smokeping

# User Feedback

## Issues

### No graphs generated even after >15 minutes

If you are affected by this issue (a small percentage of users are) please try
setting the SPUSER environment variable to root, IE:

    sudo docker run -it --name smokeping -p 8000:80 -e SPUSER=root -d \
                dperson/smokeping

### Reporting

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/dperson/smokeping/issues).