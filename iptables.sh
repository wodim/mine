#!/bin/bash

tcp_open="http ssh 28711"
tcp_closed="ident"
udp_open="28711"
udp_closed=""

iptables -F
iptables -t nat -F

iptables -P OUTPUT ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

for i in $tcp_open; do iptables -A INPUT -p TCP -j ACCEPT --dport $i; done
for i in $tcp_closed; do iptables -A INPUT -p TCP -j REJECT --dport $i; done
for i in $udp_open; do iptables -A INPUT -p UDP -j ACCEPT --dport $i; done
for i in $udp_closed; do iptables -A INPUT -p UDP -j REJECT --dport $i; done

iptables -A INPUT -j LOG --log-level 4 --log-prefix "iptables_DROPPING "
iptables -A INPUT -j DROP
