# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Apple Silicon (M3) 対応のUbuntu box
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_version = "20240319.0.0"
  
  # VM名とホスト名
  config.vm.hostname = "monitoring-lab"
  config.vm.define "monitoring" do |node|
  end
  
  # ネットワーク設定（ポートフォワード）
  config.vm.network "forwarded_port", guest: 9090, host: 9090, id: "prometheus"
  config.vm.network "forwarded_port", guest: 3000, host: 3000, id: "grafana"
  config.vm.network "forwarded_port", guest: 9100, host: 9100, id: "node-exporter"
  
  # プライベートネットワーク
  config.vm.network "private_network", ip: "192.168.56.10"
  
  # プロバイダー設定 (VMware Fusion用)
  config.vm.provider "vmware_desktop" do |vmware|
    vmware.vmx["displayname"] = "monitoring-lab"
    vmware.vmx["memsize"] = "2048"
    vmware.vmx["numvcpus"] = "2"
    vmware.gui = false
  end
  
  # 共有フォルダ設定
  config.vm.synced_folder ".", "/vagrant", disabled: false
  
  # Ansible プロビジョニング
  config.vm.provision "ansible_local" do |ansible|
    ansible.playbook = "ansible/playbook.yml"
    ansible.inventory_path = "ansible/inventory"
    ansible.limit = "all"
    ansible.verbose = true
  end
end
