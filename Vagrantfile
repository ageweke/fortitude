# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Sets up an environment for Fortitude development.
# To run test suite:
#   cd /vagrant
#   bundle exec rake spec
#
Vagrant.require_version ">= 1.7.0"

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  config.vm.provision "ruby", type: "shell" do |s|
    s.inline = <<-SCRIPT
      # Install needed packages
      sudo apt-get -y install git libsqlite3-dev zlib1g-dev nodejs ruby-dev make

      # Install Bundler
      su - vagrant -c "sudo gem install bundler"

      # Install all Fortitude dependencies
      su - vagrant -c "cd /vagrant && bundle install && rake compile"
    SCRIPT
  end
end
