# DualStack ipv4/ipv6 on openstack


## Using IPI

### install-config.yaml

```bash
cat <<EOF > install-config.yaml
apiVersion: v1
baseDomain: clustership.com
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 0
  platform:
    openstack:
      type: ocp.worker
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
  platform:
    openstack:
      type: m1.xlarge
metadata:
  creationTimestamp: null
  name: osp-ocp4-04
networking:
  clusterNetwork:
  - cidr: 10.132.0.0/14
    hostPrefix: 23
  - cidr: fd01::/48
    hostPrefix: 64
  machineNetwork:
  - cidr: 10.3.0.0/16
  - cidr: fd2e:6f44:5dd8:c956::/120
  networkType: OVNKubernetes
  serviceNetwork:
  - 172.32.0.0/16
  - fd02::/112
platform:
  openstack:
    apiVIP: 10.3.0.5
    cloud: phuet
    computeFlavor: m1.xlarge
    externalDNS: null
    externalNetwork: public
    ingressVIP: 10.3.0.7
    lbFloatingIP: 192.168.168.118
    ingressFloatingIP: 192.168.168.108
publish: External
pullSecret: '{...}'
sshKey: |
  ssh-rsa ...
EOF

cat <<EOF > install.sh
#!/bin/bash

rm -fr deploy && mkdir deploy

cp install-config.yaml deploy
# openshift-install create manifests --dir=deploy --log-level=debug
openshift-install create cluster --dir=deploy --log-level=debug
EOF

chmod 700 install.sh && ./install.sh

DEBUG       Loading Platform...
FATAL failed to fetch Metadata: failed to load asset "Install Config": invalid "install-config.yaml" file: networking: Invalid value: "DualStack": dual-stack IPv4/IPv6 is not supported for this platform, specify only one type of address
```


## Conclusion

Does not work on OpenStack
