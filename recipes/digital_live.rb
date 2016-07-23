#
# Cookbook Name:: nt-deploy
# Recipe:: digital_live
#
# Copyright 2016, National Theatre
#
# All rights reserved - Do Not Redistribute
#
service "httpd" do
  action :nothing
end

selinux_policy_boolean 'httpd_can_network_connect' do
    value true
    notifies :restart,'service[httpd]', :delayed
end

selinux_policy_boolean 'httpd_use_nfs' do
    value true
    notifies :restart,'service[httpd]', :delayed
end

cookbook_file '/opt/rh/php55/root/etc/php.d/opcache.ini' do
  source 'opcache-wordpress.ini'
  owner 'apache'
  group 'apache'
  mode '0644'
  action :create
  notifies :restart,'service[httpd]', :delayed
end

package 'nfs-utils'

Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
command = 'curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone'
command_out = shell_out(command)
region = command_out.stdout

directory "/var/www/efs" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
end

mount 'code_base' do
    device "#{region}.fs-4dd33d84.efs.eu-west-1.amazonaws.com:/"
    fstype 'nfs4'
    mount_point '/var/www/efs'
    action [:enable, :mount]
    options "noatime,nfsvers=4.1"
end
