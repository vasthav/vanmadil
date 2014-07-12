#!/bin/bash
WHITELIST=whitelist.txt
BLACKLIST=blacklist.txt
ALLOWEDTCP="80 3128 3784"
ALLOWEDUDP="3128 3784"

#THIS WILL CLEAR ALL EXISTING RULES!
echo 'Clearing all rules'
iptables -F

## Whitelist
for x in `grep -v ^# $WHITELIST | awk '{print $1}'`; do
        echo "Permitting $x..."
        $IPTABLES -A INPUT -t filter -s $x -j ACCEPT
done

## Blacklist
for x in `grep -v ^# $BLACKLIST | awk '{print $1}'`; do
        echo "Denying $x..."
        $IPTABLES -A INPUT -t filter -s $x -j DROP
done

## Permitted Ports
for port in $ALLOWEDTCP; do
       echo "Accepting port TCP $port..."
       $IPTABLES -A INPUT -t filter -p tcp --dport $port -j ACCEPT
done

for port in $ALLOWEDUDP; do
        echo "Accepting port UDP $port..."
        $IPTABLES -A INPUT -t filter -p udp --dport $port -j ACCEPT
done
