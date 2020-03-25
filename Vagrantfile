# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
#  config.vm.box_url = "http://files.vagrantup.com/lucid32.box"

  config.vm.define "tomcat" do |tomcat|
#    tomcat.vm.network "private_network", ip: "192.168.1.33", virtualbox__intnet: true
    tomcat.vm.network "forwarded_port", guest: 8080, host: 8089, auto_correct: true
    tomcat.vm.provision "shell", inline: "sudo apt-get update && sudo apt-get install -y puppet"
    tomcat.vm.provision :puppet do |puppet|
      puppet.manifests_path = "manifests"
      puppet.manifest_file = "tomcat.pp"
    end
  end
end
