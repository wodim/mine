#!/bin/bash

# CONFIGURATION
# your user id as seen on http://tunnelbroker.net/
USERID=""
# your tunnel id as seen on its config page (tunnel_detail.php?tid=X)
TUNNELID=""
# your password
PASSWORD=""
# ipv6 tunnel endpoint's server ipv4 address
ENDPOINT=""
# ipv6 tunnel endpoint's client ipv6 address
# THIS IS NOT YOUR /64 NOR YOUR /48 ROUTED PREFIX!!!
PREFIX=""

PASSWORD=$(echo -n $PASSWORD | md5sum | cut -d ' ' -f1)
modprobe ipv6
echo -!- Querying current IP address
IP=`curl -s "http://vortigaunt.net/ip/"`
echo -!- Current IP address detected as $IP
echo -!- Deactivating firewall
/etc/iptables-off.sh
echo -!- Updating IP address on tunnelbroker.net
curl -s "http://ipv4.tunnelbroker.net/ipv4_end.php?ipv4b=$IP&pass=$PASSWORD&user_id=$USERID&tunnel_id=$TUNNELID" -o /dev/null
echo -!- Reactivating firewall
/etc/iptables.sh
echo -!- Deactivating tunnels \(if any\)
modprobe -r sit
modprobe sit
echo -!- Creating new tunnel
ifconfig sit0 up
ifconfig sit0 inet6 tunnel ::$ENDPOINT 2> /dev/null
ifconfig sit1 up
ifconfig sit1 inet6 add $PREFIX
route -A inet6 add ::/0 dev sit1
echo -!- Done!
echo -!- Remember: to add new addresses, use ifconfig sit1 inet6 add [address]
