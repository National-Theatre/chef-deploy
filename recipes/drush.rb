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
  not_if { ::File.exists?("/root/.composer/vendor/bin/drush")}
end

execute 'link_drush' do
  command 'ln -s /root/.composer/vendor/bin/drush /usr/bin/drush'
  only_if { ::File.exists?("/root/.composer/vendor/bin/drush")}
  not_if { ::File.exists?("/usr/bin/drush")}
end
