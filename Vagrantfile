# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
 config.vm.define "acs" do |acs|
  acs.vm.box="centos/7"
  acs.vm.hostname = "acs"
  acs.vm.provider "virtualbox" do |vb|
   vb.cpus= 2
   vb.memory = 2048
  end
 end
 
 config.vm.define "web" do |web|
  web.vm.box="centos/7"
  web.vm.hostname = "web"
  web.vm.provider "virtualbox" do |node1|
   node1.cpus = 2
   node1.memory = 2048
  end
 end

 config.vm.define "db" do |db|
  db.vm.box="centos/7"
  db.vm.hostname="db"
  db.vm.provider "virtualbox" do |node2|
   node2.cpus = 2
   node2.memory = 2048
  end
 end

end
