#!/bin/bash

#Extract Zone ID for Domain
function grabzoneid() {

  #Strip Subdomain to get bare domain
  BASEDOMAIN=$(sed 's/.*\.\(.*\..*\)/\1/' <<< $LE_DOMAINS)

  #Grab Zoneid & Export for Hooks.sh
  export ZONEID=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones" \
    -H "X-Auth-Email: $CF_EMAIL" \
    -H "X-Auth-Key: $CF_APIKEY" \
    -H "Content-Type: application/json" | jq -r '.result[] | (select(.name | contains("'$BASEDOMAIN'"))) | .id')
}

#Grab id from existing A record
function grabaid() {

  AID=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records" \
    -H "X-Auth-Email: $CF_EMAIL"\
    -H "X-Auth-Key: $CF_APIKEY"\
    -H "Content-Type: application/json" | jq -r '.result[] | (select(.name | contains("'$LE_DOMAINS'"))) | (select (.type | contains("A"))) | .id')

}

#Create A record
function createarecord() {

  echo "Creating A record for $LE_DOMAINS at $IP"
  curl -sX POST "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records"\
    -H "X-Auth-Email: $CF_EMAIL"\
    -H "X-Auth-Key: $CF_APIKEY"\
    -H "Content-Type: application/json"\
    --data '{"type":"A","name":"'$LE_DOMAINS'","content":"'$IP'","proxied":false}' -o /dev/null

}

#Update A record IP address
function updateip() {

  echo "Updating $LE_DOMAINS with IP: $1"
  curl -sX PUT "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$AID"\
    -H "X-Auth-Email: $CF_EMAIL"\
    -H "X-Auth-Key: $CF_APIKEY"\
    -H "Content-Type: application/json"\
    --data '{"type":"A","name":"'$LE_DOMAINS'","content":"'$1'","proxied":false}' -o /dev/null

}
