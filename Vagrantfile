# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'phusion-open-ubuntu-14.04-amd64'
  config.vm.box_url = 'https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box'
  
  config.vm.network :forwarded_port, guest: 3000, host: 3000    # puma
  config.vm.network :forwarded_port, guest: 3001, host: 3001    # puma
  config.vm.network :forwarded_port, guest: 5432, host: 5433    # postgres
  config.vm.network :forwarded_port, guest: 27017, host: 27018  # mongo
  config.vm.network :forwarded_port, guest: 28017, host: 28018  # mongo web
  config.vm.network :forwarded_port, guest: 2181, host: 2181    # zookeeper
  
  config.vm.synced_folder 'data', '/cellect_data'
  
  config.vm.provision :shell, inline: <<-BASH
    mkdir -p /postgres_data /mongo_data/db; \
    cd /home/vagrant && rm -rf docker-postgresql; \
    git clone https://github.com/Painted-Fox/docker-postgresql.git
  BASH
  
  config.vm.provision 'docker' do |d|
    d.pull_images 'edpaget/zookeeper'
    # d.pull_images 'paintedfox/postgresql' # currently broken
    d.pull_images 'dockerfile/mongodb'
    
    d.build_image '/home/vagrant/docker-postgresql', args: '-t paintedfox/postgresql'
    
    d.run 'paintedfox/postgresql',
          args: '--name pg --publish 5432:5432 --env USER="cellect" --env DB="cellect" --env PASS="ce11ect!" -v /postgres_data:/data -v /cellect_data:/cellect_data'
    
    d.run 'dockerfile/mongodb',
          args: '--name mongo --publish 27017:27017 --publish 28017:28017  -v /mongo_data:/data',
          cmd: '--rest'
    
    d.run 'edpaget/zookeeper:3.4.6',
          args: '--name zk --publish 2181:2181',
          cmd: '-c localhost -i 1'
    
    d.build_image '/vagrant', args: '-t parrish/cellect'
    d.run 'cellect-1', image: 'parrish/cellect',
          args: '--publish 3000:80 --link pg:pg --link mongo:mongo --link zk:zk -v /vagrant:/cellect'
    d.run 'cellect-2', image: 'parrish/cellect',
          args: '--publish 3001:80 --link pg:pg --link mongo:mongo --link zk:zk -v /vagrant:/cellect'
  end
  
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '8192']
    vb.customize ['modifyvm', :id, '--cpus', '4']
  end
end
