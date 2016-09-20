#!/bin/sh

# Script Arguments:
# $1 -  Vlan ID for the segments to route
# $2 -  The router's ipv4 address in physnet1
# $3 -  The router's ipv4 address in physnet2
# $4 -  The router's ipv6 address in physnet1
# $5 -  The router's ipv6 address in physnet2
# $6 -  The prefixlen to be used to set up the router's ipv4 addresses
# $6 -  The prefixlen to be used to set up the router's ipv6 addresses
VLAN_ID=$1
ETH2_IPV4_ADDR=$2
ETH4_IPV4_ADDR=$3
ETH2_IPV6_ADDR=$4
ETH4_IPV6_ADDR=$5
IPV4_PREFIXLEN=$6
IPV6_PREFIXLEN=$7

sudo modprobe 8021q
sudo vconfig add eth2 $VLAN_ID
sudo vconfig add eth4 $VLAN_ID

sudo ifconfig eth2 0.0.0.0 up
sudo ifconfig eth2.$VLAN_ID $ETH2_IPV4_ADDR/$IPV4_PREFIXLEN up
sudo ifconfig eth2.$VLAN_ID inet6 add $ETH2_IPV6_ADDR/$IPV6_PREFIXLEN

sudo ifconfig eth4 0.0.0.0 up
sudo ifconfig eth4.$VLAN_ID $ETH4_IPV4_ADDR/$IPV4_PREFIXLEN up
sudo ifconfig eth4.$VLAN_ID inet6 add $ETH4_IPV6_ADDR/$IPV6_PREFIXLEN

sudo iptables -t nat -A POSTROUTING -o eth2.$VLAN_ID -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o eth4.$VLAN_ID -j MASQUERADE
sudo ip6tables -t nat -A POSTROUTING -o eth2.$VLAN_ID -j MASQUERADE
sudo ip6tables -t nat -A POSTROUTING -o eth4.$VLAN_ID -j MASQUERADE
sudo bash -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
sudo bash -c 'echo 1 > /proc/sys/net/ipv6/conf/all/forwarding'
