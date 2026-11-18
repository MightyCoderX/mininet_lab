#!/bin/bash
set -e

mkdir -p /var/run/openvswitch /var/log/openvswitch /etc/openvswitch
[ -f /etc/openvswitch/conf.db ] ||
	ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema

ovsdb-server --remote=punix:/var/run/openvswitch/db.sock \
	--remote=db:Open_vSwitch,Open_vSwitch,manager_options \
	--pidfile --detach
ovs-vsctl --no-wait init
ovs-vswitchd --pidfile --detach

exec "$@"
