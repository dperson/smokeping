#!/usr/bin/env bash
#===============================================================================
#          FILE: smokeping.sh
#
#         USAGE: ./smokeping.sh
#
#   DESCRIPTION: Entrypoint for smokeping docker container
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: David Personette (dperson@gmail.com),
#  ORGANIZATION:
#       CREATED: 2014-10-16 02:56
#      REVISION: 1.0
#===============================================================================

set -o nounset                              # Treat unset variables as an error

### gmail: Configure ssmtp for gmail
# Arguments:
#   user) gmail user
#   pass) gmail password
# Return: ssmtp will be able to send mail
gmail() {
    local user=$1
    local pass=$2
    local aliasfile=/etc/ssmtp/revaliases
    local conf=/etc/ssmtp/ssmtp.conf

    sed -i '/^root/d' $aliasfile
    echo "root:${user}+smokeping@gmail.com:smtp.gmail.com:587" >> $aliasfile

    sed -i 's/^\(root=\).*/\1'"$user"'+smokeping@gmail.com/' $conf
    sed -i 's/^\(mailhub=\).*/\1smtp.gmail.com:587/' $conf
    sed -i 's/^#*\(rewriteDomain=\).*/\1gmail.com/' $conf
    sed -i 's/^\(hostname=\).*/\1localhost/' $conf
    sed -i '/^hostname=localhost$/a \
\
# Use SSL/TLS before starting negotiation\
#UseTLS=Yes\
UseSTARTTLS=Yes\
\
# Username/Password\
AuthUser='"$user"'\
AuthPass='"$pass"'
                ' $conf
    sed -i 's/^#*\(FromLineOverride=\).*/\1YES/' $conf
}

### email: Configure owners email address
# Arguments:
#   email) your email address
# Return: setup owners email
email() {
    local email=$1
    local file=/etc/smokeping/config.d/General

    sed -i "s/^\(contact  = \).*/\\1$email/" $file
}

### owner: Configure owners name
# Arguments:
#   name) your name
# Return: setup owners name
owner() {
    local name=$1
    local file=/etc/smokeping/config.d/General

    sed -i "s/^\(owner    = \).*/\\1$name/" $file
}

### target: Configure a smokeping target
# Arguments:
#   site) name for site of tests
#   name) name for check
#   target) hostname or IP to check
#   alert) send emails on failures
# Return: setup smokeping target
target() {
    local site=$1
    local name=$2
    local target=$3
    local alert=${4:-""}
    local file=/etc/smokeping/config.d/Targets

    ## Site
    grep -q "^+ $site\$" $file || sed -i '$a \
\
+ '"$site"'\
menu = '"$site"'\
title = '"$site" Network'
                ' $file

    ## Target
    sed -i '/^++ '"$name"'$/,/^$/d; /^++ '"$name"'$/,$d' $file
    local line="$(grep -n "^+ " $file | cut -d: -f1 |
                sed "0,/^$(grep -n "^+ $site\$" $file | cut -d: -f1)\$/d" |
                head -n 1 | grep '[0-9]' || echo '$')"
    sed -i "$line"'a \
\
++ '"$name"'\
menu = '"$name"'\
title = '"$name"'\
host = '"$target"'\
'"$([[ "${alert:-""}" ]] && echo "alerts = someloss")"'
                ' $file
}

### timezone: Set the timezone for the container
# Arguments:
#   timezone) for example EST5EDT
# Return: the correct zoneinfo file will be symlinked into place
timezone() {
    local timezone="${1:-EST5EDT}"

    [[ -e /usr/share/zoneinfo/$timezone ]] || {
        echo "ERROR: invalid timezone specified" >&2
        return
    }

    ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
}

### wipe: wipe out the current targets
# Arguments:
#   none)
# Return: no defined targets
wipe() {
    local file=/etc/smokeping/config.d/Targets

    sed -i '/^+/,$d' $file
}

### usage: Help
# Arguments:
#   none)
# Return: Help text
usage() {
    local RC=${1:-0}

    echo "Usage: ${0##*/} [-opt] [command]
Options (fields in '[]' are optional, '<>' are required):
    -h          This help
    -e \"<email>\" Configure email address for owner of smokeping
                required arg: \"<email>\" - your email address
    -o \"<name>\" Configure name of the owner of smokeping
                required arg: \"<name>\" - your name
    -g \"<user;pass>\" Configure ssmtp so that email alerts can be sent
                required arg: \"<user>\" - your gmail username
                required arg: \"<pass>\" - your gmail password of app password
                These are only set in your docker container
    -t \"<site;name;target>[;alert]\" Configure smokeping targets
                required arg: \"<site>\" - name for site of tests
                required arg: \"<name>\" - name for check
                required arg: \"<target>\" - hostname or IP to check
                possible arg: \"[alert]\" - send emails on failures
    -T \"\"       Configure timezone
                possible arg: \"[timezone]\" - zoneinfo timezone for container
    -w          Wipe the targets clean

The 'command' (if provided and valid) will be run instead of nginx
" >&2
    exit $RC
}

while getopts ":hg:e:o:t:T:w" opt; do
    case "$opt" in
        h) usage ;;
        g) eval gmail $(sed 's/^\|$/"/g; s/;/" "/g' <<< $OPTARG) ;;
        e) email $OPTARG ;;
        o) owner $OPTARG ;;
        t) eval target $(sed 's/^\|$/"/g; s/;/" "/g' <<< $OPTARG) ;;
        T) timezone $OPTARG ;;
        w) wipe ;;
        "?") echo "Unknown option: -$OPTARG"; usage 1 ;;
        ":") echo "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

[[ -d /var/lib/smokeping ]] || mkdir -p /var/lib/smokeping
[[ -d /var/run/smokeping ]] || mkdir -p /var/run/smokeping
chown -Rh smokeping:www-data /var/cache/smokeping /var/lib/smokeping \
            /var/run/smokeping
chmod -R g+ws /var/cache/smokeping /var/lib/smokeping /var/run/smokeping

if [[ $# -ge 1 && -x $(which $1 2>&-) ]]; then
    exec "$@"
elif [[ $# -ge 1 ]]; then
    echo "ERROR: command not found: $1"
    exit 13
else
    service smokeping start
    chmod 0777 /dev/stderr /dev/stdout
    exec lighttpd -D -f /etc/lighttpd/lighttpd.conf
fi
