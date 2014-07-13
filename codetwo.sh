#!/bin/bash
WHITELIST=/usr/local/etc/whitelist.txt
BLACKLIST=/usr/local/etc/blacklist.txt
ALLOWED="22 25 53 80 443 465 587 993"
IPTABLES=/sbin/iptables
IPTABLES_SAVE=/sbin/iptables-save
iptables-save > /usr/local/etc/iptables.last
iptables -P INPUT ACCEPT
echo 'Setting default INPUT policy to ACCEPT'

$IPTABLES -F
echo 'Clearing Tables F'
$IPTABLES -X
echo 'Clearing Tables X'
$IPTABLES -Z
echo 'Clearing Tables Z'

$IPTABLES -F -t nat
echo 'Clearing nat Tables F'
$IPTABLES -F -t mangle
echo 'Clearing Tables X'
$IPTABLES -F -t raw
echo 'Clearing Tables Z'


#echo 'Allowing Localhost'
#$IPTABLES -A INPUT -s 127.0.0.1 -j ACCEPT

## Whitelist
#for x in `grep -v ^# $WHITELIST | awk '{print $1}'`; do
#echo "Permitting $x..."
#$IPTABLES -A INPUT -s $x -j ACCEPT
#done

for x in `grep -v ^# $WHITELIST | awk '{print $1}'`; do
echo "Permitting $x..."
$IPTABLES -A OUTPUT -d $x -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
done

## Blacklist
#for x in `grep -v ^# $BLACKLIST | awk '{print $1}'`; do
#echo "Denying $x..."
#$IPTABLES -A INPUT -s $x -j DROP
#done

## Permitted Ports
for port in $ALLOWED; do
echo "Accepting port TCP $port..."
$IPTABLES -A INPUT -p tcp --dport $port -j ACCEPT
done

for port in $ALLOWED; do
echo "Accepting port UDP $port..."
$IPTABLES -A INPUT -p udp --dport $port -j ACCEPT
done

$IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
#$IPTABLES -A OUTPUT -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
$IPTABLES -A INPUT -p udp -j DROP
$IPTABLES -A INPUT -p tcp --syn -j DROP
$IPTABLES -A INPUT -j DROP
$IPTABLES -A OUTPUT -j DROP

iptables-save > /etc/iptables/rules.v4
#clear
iptables -vnL --line-number
