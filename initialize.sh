#!/bin/bash
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F 
iptables-save > /etc/iptables/rules.v4
iptables -vnL
