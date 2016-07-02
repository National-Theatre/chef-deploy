#
# Cookbook Name:: nt-deploy
# Recipe:: drush
#
# Copyright 2016, National Theatre
#
# All rights reserved - Do Not Redistribute
#

remote_file '/usr/bin/composer' do
  source 'https://getcomposer.org/composer.phar'
  owner 'apache'
  group 'apache'
  mode '0755'
  action :create
end

directory "/home/ec2-user/.config/composer" do
  mode '0755'
  owner 'ec2-user'
  group 'ec2-user'
  action :create
  recursive true
end
template "/home/ec2-user/.config/composer/auth.json" do
  source "auth.json.erb"
  mode '0600'
  owner 'ec2-user'
  group 'ec2-user'
  variables ({
    :token => node['nt-deploy']['github']
  })
end

execute 'get_drush' do
  command 'composer global require drush/drush'
  not_if { ::File.exists?("/home/ec2-user/.config/composer/vendor/bin/drush")}
  user 'ec2-user'
  group 'ec2-user'
  environment ({"COMPOSER_HOME" => "/home/ec2-user/.config/composer"})
end

link '/usr/bin/drush' do
  to '/home/ec2-user/.config/composer/vendor/bin/drush'
  only_if { ::File.exists?("/home/ec2-user/.config/composer/vendor/bin/drush")}
  owner 'ec2-user'
  group 'ec2-user'
end
