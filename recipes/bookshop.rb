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

if (::File.exists?("/swap.img") == false)
  Chef::Log.info("Swapfile not found. Manually creating one of 512M for OOM safety")
  execute "creating swapfile" do
    command "/bin/dd if=/dev/zero of=/swap.img bs=1M count=512"
    action :run
    creates "/swap.img"
  end

  execute "formatting swapfile" do
    command "/sbin/mkswap -L local /swap.img"
    action :run
  end

  mount "none" do
    device "/swap.img"
    fstype "swap"
    options [ "sw"]
    dump 0
    pass 0
    action :enable
  end

  execute "mounting swapfile" do
    command "/sbin/swapon -a"
    action :run
  end
end
