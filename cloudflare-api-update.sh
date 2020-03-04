#!/bin/bash
# Author: Hugo <mail@hugo.ro>
#
# Dynamically update DNS on cloudflare through their API.
# Uses jq and python (dirty, I know!).
# Set CONFIG values to your needs.

# --- CONFIG START ---
# If the first 3 variables are set, the script tries to get the current IP from your Fritz!Box,
# so it doesn't need a call to ipecho.net to get it.
# For this to work, you'll need this tool: https://github.com/jhubig/FritzBoxShell
# Please escape the password accordingly and uncomment these lines.

#BoxUSER="fritzbox_user"
#BoxPW="fritzbox_pass"
#BoxShell="/usr/sbin/fritzBoxShell.sh"

# See the cloudflare API documentation about how to get following values for your account: https://api.cloudflare.com/#zone-list-zones
API_ID="me@example.com"
API_AUTH_KEY="foo47eb745079dac9320b638f5e225cf483cc5cfdda41"
ZONE_NAME="example.com"
ZONE_ID="bar1105f4ecef8ad9ca31a8372d0c353"
DNSREC_ID="baz372954025e0ba6aaa6d586b9e0b59"
# --- CONFIG END ---

# No need to change anything beyond this point

# show usage
usage() {
  printf "\nUsage:\n\n"
  printf "$(basename $0) [-f|--force]\n"
  printf "      -f | --force - Force DNS update\n"
  printf "      -d | --debug - Enable debug\n"
}

# get command line switches
while [ -n "$1" ]; do
    case "$1" in
        -f | --force)
            FORCE=true
            ;;
        -d | --debug)
            DEBUG=true
            ;;
        *)
            printf "Unknown argument: $1\n"
            usage
            exit 1
            ;;
    esac
    shift
done

# get IP from cloudflare
DNS_IP=`curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNSREC_ID" \
     -H "X-Auth-Email: $API_ID" \
     -H "X-Auth-Key: $API_AUTH_KEY" \
     -H "Content-Type: application/json" | python -m json.tool | grep content | awk -F\" '{print $4}'`

if [ $BoxUSER ] && [ $BoxPW ] && [ $BoxShell ]; then
  # use IP from Fritz!Box
  CURRENT_IP=`$BoxShell IGDIP STATE | grep NewExternalIPAddress | awk '{print $2}'`
else
  # get IP from ipecho.net
  CURRENT_IP=`wget http://ipecho.net/plain -O - -q ; echo`
fi

if [ "$DNS_IP" != "$CURRENT_IP" ] || [ $FORCE ]; then
  UPDATE=`curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNSREC_ID" \
       -H "X-Auth-Email: $API_ID" \
       -H "X-Auth-Key: $API_AUTH_KEY" \
       -H "Content-Type: application/json" \
       --data '{"type":"A","name":"'"$ZONE_NAME"'","content":"'"$CURRENT_IP"'","ttl":1,"proxied":false}'  | python -m json.tool`
  SUCCESS=`echo "$UPDATE" | jq .'success'`
  DBG="INFO - renewed IP with: '$CURRENT_IP', success=$SUCCESS"
  logger --tag cloudflare-update $DBG
else
  DBG="INFO - IP unchanged: '$CURRENT_IP'"
  logger --tag cloudflare-update $DBG
fi

if [ $DEBUG ]; then
  echo "CURRENT_IP=$CURRENT_IP"
  echo "DNS_IP=$DNS_IP"
  if [ $SUCCESS ]; then
    echo $UPDATE | python -m json.tool
  fi
  echo "$DBG"
fi
