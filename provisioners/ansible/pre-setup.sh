#!/bin/bash

base_dir=${BASE_DIR:-~/gemini/provisioners/ansible/playbooks/roles}

#TODO: For loop that checks if ${base_dir}/$file exists before cloning the repos.
# Pull gemini ansible repos
git clone https://github.com/gemini-project/ansible-role-ansible-controller.git ${base_dir}/ansible-controller
git clone -b pxe_coreos https://github.com/gemini-project/ansible-role-httpd.git ${base_dir}/httpd
git clone -b pxe_coreos https://github.com/gemini-project/ansible-role-tftp.git ${base_dir}/tftp
git clone -b pxe_coreos https://github.com/gemini-project/ansible-dnsmasq.git ${base_dir}/dnsmasq
git clone -b pxe_coreos https://github.com/gemini-project/ansible-coreos-cloudinit.git ${base_dir}/coreos-cloudinit

# Show the populated roles directory
ls -al ${base_dir}

# Pre-setup complete
echo "-> Your Gemini Ansible roles have been successfully created"
