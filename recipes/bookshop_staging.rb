#
# Cookbook Name:: nt-deploy
# Recipe:: bookshop_staging
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

ruby_block "get_region" do
    block do
        #tricky way to load this Chef::Mixin::ShellOut utilities
        Chef::Resource::RubyBlock.send(:include, Chef::Mixin::ShellOut)      
        command = 'curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone'
        command_out = shell_out(command)
        node.set['aws_region'] = command_out.stdout
    end
    action :create
end

directory "/var/www/bookshop/magento" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
  end

mount 'code_base' do
    device "#{node['aws_region']}.fs-24678aed.efs.eu-west-1.amazonaws.com"
    fstype 'nfs4'
    mount_point '/var/www/bookshop/magento'
    action [:enable, :mount]
    options "_netdev,allow_other,nonempty,noatime,nfsvers=4.1"
end

selinux_policy_boolean 'httpd_use_nfs' do
    value true
    notifies :restart,'service[httpd]', :delayed
end


keys = data_bag('bookshop')

nt_deploy_magento "bookshop" do
    use_bundle true
    site_dns 'bookshop.ntstaging.org'
    db_user 'bookshop'
    db_pwd data_bag_item('bookshop', 'staging')['pwd']
    cache_prefix 'bs_'
    salt data_bag_item('bookshop', 'staging')['salt']
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

link '/var/www/bookshop/magento/var/aitreports' do
  to '/var/www/bookshop/magento/media/aitreports'
  group 'apache'
  owner 'apache'
end

link '/var/www/bookshop/magento/var/smartreports' do
  to '/var/www/bookshop/magento/media/smartreports'
  group 'apache'
  owner 'apache'
end

