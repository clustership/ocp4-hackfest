#!/bin/bash

cluster_name=`egrep cluster_name: cluster.yml | awk '{ print $2 }'`

virsh destroy ${cluster_name}-bootstrap
virsh undefine ${cluster_name}-bootstrap

for i in $(seq 0 2)
do
  virsh destroy ${cluster_name}-master-${i}
  virsh undefine ${cluster_name}-master-${i}
done

for i in $(seq 0 1)
do
  virsh destroy ${cluster_name}-worker-${i}
  virsh undefine ${cluster_name}-worker-${i}
done


virsh net-destroy --network ${cluster_name}
virsh net-undefine --network ${cluster_name}

virsh net-destroy --network ${cluster_name}-internal
virsh net-undefine --network ${cluster_name}-internal

rm -f /var/lib/libvirt/images/${cluster_name}*.qcow2
