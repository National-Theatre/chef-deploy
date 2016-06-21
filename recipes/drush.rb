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

execute 'get_drush' do
  command 'composer global require drush/drush'
  not_if { ::File.exists?("/home/ec2-user/.config/composer/vendor/bin/drush")}
  user 'ec2-user'
  group 'ec2-user'
end

link '/usr/bin/drush' do
  to '/home/ec2-user/.config/composer/vendor/bin/drush'
  only_if { ::File.exists?("/home/ec2-user/.config/composer/vendor/bin/drush")}
  owner 'ec2-user'
  group 'ec2-user'
end
