#!/bin/sh

SW=switch0
IF=eth0

swconfig dev $SW set reset

swconfig dev $SW set enable_vlan 1
swconfig dev $SW vlan 1 set ports "1 2 3 4 6t"
swconfig dev $SW vlan 2 set ports "0 6t"

swconfig dev $SW set apply

ip link set $IF up
ip link add link $IF name ${IF}.1 type vlan id 1
ip link add link $IF name ${IF}.2 type vlan id 2

MTDBLK=/dev/mtdblock2
LAN_ADDR=$(xxd -s 0x28 -l6 -p $MTDBLK | sed -e 's/\(..\)/\1:/g' -e 's/:$//')
WAN_ADDR=$(xxd -s 0x2e -l6 -p $MTDBLK | sed -e 's/\(..\)/\1:/g' -e 's/:$//')

LAN_IF=${IF}.1
WAN_IF=${IF}.2

ip link set dev $LAN_IF address $LAN_ADDR
ip link set dev $WAN_IF address $WAN_ADDR

ip link set $LAN_IF up
ip link set $WAN_IF up

