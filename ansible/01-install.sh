#!/usr/bin/env ansible-playbook
---
# If you like to play: ./ansible/create.yml --skip-tags public_dns,letsencrypt
- hosts: localhost
  connection: local
  # gather_facts true because we need the public ip address
  gather_facts: true
  become: true
  vars_files:
  - ./vars.yml
  vars:
    openshift_location: "{{ openshift_mirror }}/pub/openshift-v4/clients/ocp-dev-preview/{{openshift_client_version}}"

  tasks:
  - name: Install required openshift tools
    import_role:
      name: openshift-assets-install
      tasks_from: download-openshift-artifacts.yml
