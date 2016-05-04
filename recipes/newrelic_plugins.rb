#
# Cookbook Name:: nt-deploy
# Recipe:: newrelic_plugins
#
# Copyright 2016, National Theatre
#
# All rights reserved - Do Not Redistribute
#

service "newrelic-plugin-agent" do
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

cookbook_file '/var/www/html/newrelic-phpopcache.php' do
  source 'newrelic-phpopcache.php'
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
    notifies :start, 'service[newrelic-plugin-agent]', :immediately
    notifies :restart, 'service[newrelic-plugin-agent]', :delayed
end

template "/etc/newrelic/newrelic-phpopcache.ini" do
    source "newrelic-phpopcache.ini.erb"
    mode '0440'
    owner 'apache'
    group 'apache'
    variables ({
      :key   => node['newrelic']['license'],
      :name   => node['instance_name'],
      :poll_cycle => 60
    })
end

cron_d "newrelic_opcache" do
    command "curl http://127.0.0.1/newrelic-phpopcache.php 2&>1 > /dev/null"
    user    'apache'
end
