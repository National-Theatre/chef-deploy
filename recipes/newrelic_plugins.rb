#
# Cookbook Name:: nt-deploy
# Recipe:: newrelic_plugins
#
# Copyright 2016, National Theatre
#
# All rights reserved - Do Not Redistribute
#

cookbook_file '/usr/lib/systemd/system/newrelic-plugin.service' do
  source 'newrelic-plugin.service'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

service "newrelic-plugin" do
  action :enable
end

service "httpd" do
  action :enable
end

cookbook_file '/var/www/html/apc-nrp.php' do
  source 'apc-nrp.php'
  owner 'apache'
  group 'apache'
  mode '0644'
  action :create
end

cookbook_file '/etc/httpd/conf.d/000-localhost.conf' do
  source '000-localhost.conf'
  owner 'apache'
  group 'apache'
  mode '0644'
  action :create
  notifies :restart, 'service[httpd]', :delayed
end

template "/etc/newrelic/newrelic-plugin-agent.cfg" do
    source "newrelic-plugin-agent.cfg.erb"
    mode '0440'
    owner 'apache'
    group 'apache'
    variables ({
      :key   => node['newrelic']['license'],
      :name   => node['instance_name']
    })
    notifies :restart, 'service[newrelic-plugin]', :delayed
end
