#
# Cookbook Name:: nt-deploy
# Recipe:: default
#
# Copyright 2015, National Theatre
#
# All rights reserved - Do Not Redistribute
#

cookbook_file '/etc/httpd/drupal_vhost.ini' do
  source 'drupal_vhost.ini'
  mode '0544'
  owner 'apache'
  group 'apache'
end

cookbook_file '/etc/httpd/drupal_htaccess.ini' do
  source 'default_drupal.ini'
  mode '0544'
  owner 'apache'
  group 'apache'
end