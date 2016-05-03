#
# Cookbook Name:: nt-deploy
# Recipe:: sort_swap
#
# Copyright 2016, National Theatre
#
# All rights reserved - Do Not Redistribute
#

if (::File.exists?("/swap.img") == false)
  Chef::Log.info("Swapfile not found. Manually creating one of 512M for OOM safety")
  execute "creating swapfile" do
    command "/bin/dd if=/dev/zero of=/swap.img bs=1M count=#{node['nt-deploy']['swap_mem_size']}"
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
