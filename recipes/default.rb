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

selinux_policy_module 'newrelic-daemon' do
  content <<-eos
module newrelic-daemon 1.0;

require {
        type httpd_t;
        type sysctl_net_t;
        type var_log_t;
        class file read;
        class capability2 block_suspend;
        class file open;
}

#============= httpd_t ==============
allow httpd_t self:capability2 block_suspend;
allow httpd_t sysctl_net_t:file read;
allow httpd_t var_log_t:file open;
  eos
  action :deploy
end