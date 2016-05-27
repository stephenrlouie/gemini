#Gets the gemini repo

gem_ansible_dir=~/gemini-ansible/provisioners/ansible

git clone https://github.com/stephenrlouie/gemini-ansible.git && cd $gem_ansible_dir

git checkout foreman-role

#Sets the ssh user name
sed -i "s/ansible_ssh_user: my_gemini_master_user/ansible_ssh_user: vagrant/" group_vars/all.yml

#Sets docker user
sed -i "s/docker_users: \[my_gemini_master_user\]/docker_users: \[vagrant\]/" group_vars/all.yml


#removes the option router for the intnet, we only need one default gateway
#sed -i "s/dnsmasq_option_router: '10.10.10.1'/#dnsmasq_option_router: '10.10.10.1'/" group_vars/all.yml

#Default Netmask does not like this end addr
#sed -i "s/start_addr: '10.10.10.10'/start_addr: '10.10.10.30'/" group_vars/all.yml
#sed -i "s/end_addr: '10.30.118.100'/end_addr: '10.10.10.100'/" group_vars/all.yml

#Overwriting the default node example
#sed -i "s/- name: 'my_cluster_node'/- name: 'node1'/" group_vars/all.yml
#sed -i "s/mac: 'AA:BB:44:33:22:11'/mac: '00:00:00:00:00:01'/" group_vars/all.yml
#sed -i "s/ip: '10.10.10.10'/ip: '10.10.10.11'/" group_vars/all.yml

#Appending 10 more nodes to the file
#sed -i "/ip: '10.10.10.11'/r /vagrant/provision_files/nodes.txt" group_vars/all.yml

#Removing so we can append our key here
sed -i '$ d' group_vars/all.yml

#Fetches the gemini master building repos
./pre-setup.sh

#Copys the ssh key into position
echo -n " " >> $gem_ansible_dir/group_vars/all.yml
cat ~/.ssh/id_rsa.pub >> $gem_ansible_dir/group_vars/all.yml

#Replaces the ansible fact to use the correct IP address, Vagrant has to have a NAT adapter as the default, so we need to assign http, tftp, dhcp to run on the second adapter that can reach our cluster
grep -rl "ansible_default_ipv4.address" . | xargs sed -i 's/ansible_default_ipv4.address/ansible_enp0s8.ipv4.address/'

sed -i "s/ansible_eth0.ipv4.address/ansible_enp0s8.ipv4.address/g" /home/vagrant/gemini-ansible/provisioners/ansible/roles/foreman/defaults/main.yml

sed -i 's#--dont-save-answers#--foreman-proxy-dhcp-interface enp0s8 --foreman-proxy-dns-interface enp0s8 --foreman-proxy-bmc-listen-on both --foreman-proxy-dhcp-listen-on both --foreman-proxy-dns-listen-on both --foreman-proxy-tftp-listen-on both --foreman-proxy-foreman-base-url http://127.0.0.1 --foreman-proxy-http true --foreman-proxy-puppet-url http://127.0.0.1:8140 --foreman-proxy-dhcp-range \"10.10.10.11 10.10.10.250\" --foreman-ssl false --foreman-proxy-ssl false -v --dont-save-answers#' /home/vagrant/gemini-ansible/provisioners/ansible/roles/foreman/handlers/main.yml

#So no response is required to run the ansible playbook
export ANSIBLE_HOST_KEY_CHECKING=False

#Actually builds the gem master
./setup.sh
