#
# Cookbook Name:: nt-deploy
# Recipe:: bookshop_live
#
# Copyright 2015, National Theatre
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

package 'nfs-utils'

Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
command = 'curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone'
command_out = shell_out(command)
region = command_out.stdout

directory "/var/www/bookshop" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
  end

mount 'code_base' do
    device "#{region}.fs-33678afa.efs.eu-west-1.amazonaws.com:/"
    fstype 'nfs4'
    mount_point '/var/www/bookshop'
    action [:enable, :mount]
    options "noatime,nfsvers=4.1"
end

selinux_policy_boolean 'httpd_use_nfs' do
    value true
    notifies :restart,'service[httpd]', :delayed
end


keys = data_bag('bookshop')

nt_deploy_magento "bookshop" do
    use_bundle true
    site_dns 'shop.nationaltheatre.org.uk'
    db_user 'bookshop'
    db_pwd data_bag_item('bookshop', 'live')['pwd']
    cache_prefix 'bs_'
    salt data_bag_item('bookshop', 'live')['salt']
    admin_url 'ntmgtaccesslink'
end

%w{Aitoc_Aitreports.xml Aitoc_Common.xml Aitoc_Aitinstall.xml}.each do |folder|
    file "/var/www/bookshop/magento/app/etc/modules/#{folder}" do
      owner 'apache'
      group 'apache'
      mode '0664'
    end
    selinux_policy_fcontext "/var/www/bookshop/magento/app/etc/modules/#{folder}" do
      secontext 'httpd_sys_rw_content_t'
    end
end


