# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'ipaddr'

vagrant_config = YAML.load_file("provisioning/virtualbox.conf.yml")

Vagrant.configure(2) do |config|
  config.vm.box = vagrant_config['box']

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
  end

  #config.vm.synced_folder
  #config.vm.synced_folder File.expand_path("/opt/stack"), "/opt/stack"
  config.vm.synced_folder File.expand_path("/opt/stack/neutron"), "/opt/stack/neutron"
  config.vm.synced_folder File.expand_path("/opt/stack/glance"), "/opt/stack/glance"
  config.vm.synced_folder File.expand_path("/opt/stack/nova"), "/opt/stack/nova"
  config.vm.synced_folder File.expand_path("/opt/stack/tempest"), "/opt/stack/tempest"
  config.vm.synced_folder File.expand_path("/opt/stack/noVNC"), "/opt/stack/noVNC"
  config.vm.synced_folder File.expand_path("/opt/stack/cinder"), "/opt/stack/cinder"
  config.vm.synced_folder File.expand_path("/opt/stack/keystone"), "/opt/stack/keystone"
  config.vm.synced_folder File.expand_path("/opt/stack/requirements"), "/opt/stack/requirements"
  config.vm.synced_folder File.expand_path("/opt/stack/horizon"), "/opt/stack/horizon"

  # Build the common args for the setup-base.sh scripts.
  setup_base_common_args = "#{vagrant_config['allinone']['ip']} #{vagrant_config['allinone']['short_name']} " +
                           "#{vagrant_config['compute1']['ip']} #{vagrant_config['compute1']['short_name']} " +
                           "#{vagrant_config['compute2']['ip']} #{vagrant_config['compute2']['short_name']}"

  # Bring up the Devstack allinone node on Virtualbox
  config.vm.define "allinone", primary: true do |allinone|
    allinone.vm.host_name = vagrant_config['allinone']['host_name']
    allinone.vm.network "private_network", ip: vagrant_config['allinone']['ip']
    allinone.vm.provision "shell", path: "provisioning/setup-base.sh", privileged: false,
      :args => "#{vagrant_config['allinone']['mtu']} #{setup_base_common_args}"
    allinone.vm.provision "shell", path: "provisioning/setup-allinone.sh", privileged: false,
      :args => "#{vagrant_config['allinone']['vlan_interface']} " +
               "#{vagrant_config['allinone']['physical_network']} " +
               "#{vagrant_config['compute2']['physical_network']} " +
               "#{vagrant_config['multinet_segmentation_id']} " +
               "#{vagrant_config['segment1_ipv4_cidr']} #{vagrant_config['segment2_ipv4_cidr']} " +
               "#{vagrant_config['segment1_ipv6_cidr']} #{vagrant_config['segment2_ipv6_cidr']}"
    allinone.vm.provider "virtualbox" do |vb|
       vb.memory = vagrant_config['allinone']['memory']
       vb.cpus = vagrant_config['allinone']['cpus']
       vb.customize [
           'modifyvm', :id,
           '--nic3', "intnet"
          ]
       vb.customize [
           'modifyvm', :id,
           '--intnet3', "physnet1"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nicpromisc3', "allow-all"
          ]
       vb.customize [
           "guestproperty", "set", :id,
           "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000
          ]
    end
  end

  # Bring up the first Devstack compute node on Virtualbox
  config.vm.define "compute1" do |compute1|
    compute1.vm.host_name = vagrant_config['compute1']['host_name']
    compute1.vm.network "private_network", ip: vagrant_config['compute1']['ip']
    compute1.vm.provision "shell", path: "provisioning/setup-base.sh", privileged: false,
      :args => "#{vagrant_config['compute1']['mtu']} #{setup_base_common_args}"
    compute1.vm.provision "shell", path: "provisioning/setup-compute.sh", privileged: false,
      :args => "#{vagrant_config['allinone']['ip']} #{vagrant_config['compute1']['vlan_interface']} " +
               "#{vagrant_config['compute1']['physical_network']}"
    compute1.vm.provider "virtualbox" do |vb|
       vb.memory = vagrant_config['compute1']['memory']
       vb.cpus = vagrant_config['compute1']['cpus']
       vb.customize [
           'modifyvm', :id,
           '--nic3', "intnet"
          ]
       vb.customize [
           'modifyvm', :id,
           '--intnet3', "physnet1"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nicpromisc3', "allow-all"
          ]
       vb.customize [
           "guestproperty", "set", :id,
           "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000
          ]
    end
  end

  # Bring up the second Devstack compute node on Virtualbox enabled also as
  # network node
  config.vm.define "compute2" do |compute2|
    compute2.vm.host_name = vagrant_config['compute2']['host_name']
    compute2.vm.network "private_network", ip: vagrant_config['compute2']['ip']
    compute2.vm.provision "shell", path: "provisioning/setup-base.sh", privileged: false,
      :args => "#{vagrant_config['compute2']['mtu']} #{setup_base_common_args}"
    compute2.vm.provision "shell", path: "provisioning//setup-network-compute.sh", privileged: false,
      :args => "#{vagrant_config['allinone']['ip']} #{vagrant_config['compute2']['vlan_interface']} " +
               "#{vagrant_config['compute2']['physical_network']}"
    compute2.vm.provider "virtualbox" do |vb|
       vb.memory = vagrant_config['compute2']['memory']
       vb.cpus = vagrant_config['compute2']['cpus']
       vb.customize [
           'modifyvm', :id,
           '--nic3', "intnet"
          ]
       vb.customize [
           'modifyvm', :id,
           '--intnet3', "physnet1"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nicpromisc3', "allow-all"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nic4', "intnet"
          ]
       vb.customize [
           'modifyvm', :id,
           '--intnet4', "physnet2"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nicpromisc4', "allow-all"
          ]
       vb.customize [
           "guestproperty", "set", :id,
           "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000
          ]
    end
  end

  # Bring up the third Devstack compute node on Virtualbox
  config.vm.define "compute3" do |compute3|
    compute3.vm.host_name = vagrant_config['compute3']['host_name']
    compute3.vm.network "private_network", ip: vagrant_config['compute3']['ip']
    compute3.vm.provision "shell", path: "provisioning/setup-base.sh", privileged: false,
      :args => "#{vagrant_config['compute3']['mtu']} #{setup_base_common_args}"
    compute3.vm.provision "shell", path: "provisioning/setup-compute.sh", privileged: false,
      :args => "#{vagrant_config['allinone']['ip']} #{vagrant_config['compute3']['vlan_interface']} " +
               "#{vagrant_config['compute3']['physical_network']}"
    compute3.vm.provider "virtualbox" do |vb|
       vb.memory = vagrant_config['compute3']['memory']
       vb.cpus = vagrant_config['compute3']['cpus']
       vb.customize [
           'modifyvm', :id,
           '--nic3', "intnet"
          ]
       vb.customize [
           'modifyvm', :id,
           '--intnet3', "physnet1"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nicpromisc3', "allow-all"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nic4', "intnet"
          ]
       vb.customize [
           'modifyvm', :id,
           '--intnet4', "physnet2"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nicpromisc4', "allow-all"
          ]
       vb.customize [
           "guestproperty", "set", :id,
           "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000
          ]
    end
  end

  gateway_physnet1_ipv4 = (IPAddr.new vagrant_config['segment1_ipv4_cidr']).succ().to_s()
  gateway_physnet2_ipv4 = (IPAddr.new vagrant_config['segment2_ipv4_cidr']).succ().to_s()
  gateway_physnet1_ipv6 = (IPAddr.new vagrant_config['segment1_ipv6_cidr']).succ().to_s()
  gateway_physnet2_ipv6 = (IPAddr.new vagrant_config['segment2_ipv6_cidr']).succ().to_s()
  prefixlen_ipv4 = vagrant_config['segment1_ipv4_cidr'][-2..-1]
  prefixlen_ipv6 = vagrant_config['segment1_ipv6_cidr'][-2..-1]

  # Bring up the router
  config.vm.define "iprouter" do |iprouter|
    iprouter.vm.host_name = vagrant_config['iprouter']['host_name']
    iprouter.vm.network "private_network", ip: vagrant_config['iprouter']['ip']
    iprouter.vm.provision "shell", path: "provisioning/setup-base.sh", privileged: false,
      :args => "#{vagrant_config['iprouter']['mtu']} #{setup_base_common_args}"
    iprouter.vm.provision "shell", path: "provisioning/setup-iprouter.sh", privileged: false,
      :args => "#{vagrant_config['multinet_segmentation_id']} #{gateway_physnet1_ipv4} " +
               "#{gateway_physnet2_ipv4} #{gateway_physnet1_ipv6} #{gateway_physnet2_ipv6} " +
               "#{prefixlen_ipv4} #{prefixlen_ipv6}"
    iprouter.vm.provider "virtualbox" do |vb|
       vb.memory = vagrant_config['iprouter']['memory']
       vb.cpus = vagrant_config['iprouter']['cpus']
       vb.customize [
           'modifyvm', :id,
           '--nic3', "intnet"
          ]
       vb.customize [
           'modifyvm', :id,
           '--intnet3', "physnet1"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nicpromisc3', "allow-all"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nic4', "intnet"
          ]
       vb.customize [
           'modifyvm', :id,
           '--intnet4', "physnet2"
          ]
       vb.customize [
           'modifyvm', :id,
           '--nicpromisc4', "allow-all"
          ]
       vb.customize [
           "guestproperty", "set", :id,
           "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000
          ]
    end
  end
end
