# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'phusion-open-ubuntu-14.04-amd64'
  config.vm.box_url = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box'
  
  config.vm.network :forwarded_port, guest: 3000, host: 3000    # puma
  config.vm.network :forwarded_port, guest: 5432, host: 5433    # postgres
  config.vm.network :forwarded_port, guest: 27017, host: 27018  # mongo
  config.vm.network :forwarded_port, guest: 28017, host: 28018  # mongo web
  
  config.vm.provision 'docker' do |d|
    d.pull_images 'ubuntu'
    d.pull_images 'edpaget/zookeeper'
    d.pull_images 'paintedfox/postgresql'
    d.pull_images 'dockerfile/mongodb'
    
    d.run 'paintedfox/postgresql',
          args: '--name pg --publish 5432:5432 --env USER="cellect" --env DB="cellect" --env PASS="ce11ect!"'
    
    d.run 'dockerfile/mongodb',
          args: '--name mongo --publish 27017:27017 --publish 28017:28017',
          cmd: '--rest'
    
    d.run 'edpaget/zookeeper:3.4.6',
          args: '--name zk --publish-all',
          cmd: '-c localhost -i 1'
  end
  
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '4096']
    vb.customize ['modifyvm', :id, '--cpus', '4']
  end
end
