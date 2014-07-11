#!/bin/bash
WHITELIST=/usr/local/etc/whitelist.txt
BLACKLIST=/usr/local/etc/blacklist.txt
ALLOWED="22 25 53 80 443 465 587 993"
IPTABLES=/sbin/iptables
IPTABLES_SAVE=/sbin/iptables-save
$IPTABLES_SAVE > /usr/local/etc/iptables.last
$IPTABLES -P INPUT ACCEPT
echo 'Setting default INPUT policy to ACCEPT'

$IPTABLES -F
echo 'Clearing Tables F'
$IPTABLES -X
echo 'Clearing Tables X'
$IPTABLES -Z
echo 'Clearing Tables Z'

## Whitelist
for x in `grep -v ^# $WHITELIST | awk '{print $1}'`; do
echo "Permitting $x..."
$IPTABLES -A INPUT -s $x -j ACCEPT
done

## Blacklist
#for x in `grep -v ^# $BLACKLIST | awk '{print $1}'`; do
#echo "Denying $x..."
#$IPTABLES -A INPUT -s $x -j DROP
#done

## Permitted Ports
for port in $ALLOWED; do
echo "Accepting port TCP $port..."
$IPTABLES -A OUTPUT -p tcp --dport $port -j ACCEPT
done

for port in $ALLOWED; do
echo "Accepting port UDP $port..."
$IPTABLES -A OUTPUT -p udp --dport $port -j ACCEPT
done
echo 'Allowing Localhost'
$IPTABLES -A OUTPUT -s 127.0.0.1 -j ACCEPT
$IPTABLES -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A OUTPUT -p udp -j DROP
$IPTABLES -A OUTPUT -p tcp --syn -j DROP
$IPTABLES -A OUTPUT -m state --state RELATED,ESTABLISHED,NEW -j ACCEPT
iptables -A OUTPUT -j DROP
iptables-save > /etc/iptables/rules.v4

