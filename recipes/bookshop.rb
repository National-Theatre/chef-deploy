#
# Cookbook Name:: nt-deploy
# Recipe:: bookshop
#
# Copyright 2015, National Theatre
#
# All rights reserved - Do Not Redistribute
#

mount 'bucket' do
    device "s3fs##{node['s3_bucket']}"
    fstype 'fuse'
    mount_point '/var/www/bookshop/magento/media'
    action [:enable, :mount]
    options "_netdev,allow_other,nonempty,noatime,iam_role=#{node['iam_role']}"
end

selinux_policy_boolean 'httpd_use_fusefs' do
    value true
    notifies :restart,'service[httpd]', :delayed
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
