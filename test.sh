#!/bin/bash
# THE GREAT WALL
# PROGRAMMER->KC

#initializing
IPTABLES=/sbin/iptables
WHITELIST=/usr/local/etc/whitelist.txt
BLACKLIST=/usr/local/etc/blacklist.txt
INPUT_TCP="22 80 443 10000"
INPUT_UDP=""


#FLUSHING
#$IPTABLES -P INPUT ACCEPT
$IPTABLES -F
$IPTABLES -X
$IPTABLES -Z


#SETTING UP DEFAULT POLICIES
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT DROP
$IPTABLES -P FORWARD DROP
$IPTABLES -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#ALLOWING LOOPBACK
$IPTABLES -A INPUT -i lo -j ACCEPT -m comment --comment "allow loopback"
$IPTABLES -A OUTPUT -o lo -j ACCEPT -m comment --comment "allow loopback"

for x in `grep -v ^# $WHITELIST | awk '{print $1}'`; do
echo "Permitting $x..."
$IPTABLES -A INPUT --source $x -j ACCEPT
done

#
## Blacklist
#

for x in `grep -v ^# $BLACKLIST | awk '{print $1}'`; do
echo "Denying $x..."
$IPTABLES -A INPUT -s $x -j DROP
done

#ALLOWING PORTS
for port in $INPUT_TCP; do
    echo "accepting port TCP $port"
    $IPTABLES -A INPUT -t filter -p tcp --dport $port -j ACCEPT
done

for port in $INPUT_UDP; do
    echo "accepting port TCP $port"
    $IPTABLES -A INPUT -t filter -p udp --dport $port -j ACCEPT
done

 ## Drop and log the rest
    $IPTABLES -A INPUT -j LOG --log-prefix "INPUT DROP: " -m limit --limit 10/minute --limit-burst 10
    $IPTABLES -A INPUT -j DROP

## Output accept everything but 'invalid' packets
    $IPTABLES -A OUTPUT -m state --state NEW -j ACCEPT
    $IPTABLES -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    $IPTABLES -A OUTPUT -j LOG --log-prefix "OUTPUT DROP: "
    $IPTABLES -A OUTPUT -j DROP
