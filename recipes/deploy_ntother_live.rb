#
# Cookbook Name:: nt-deploy
# Recipe:: deploy_ntother_live
#
# Copyright 2016, National Theatre
#
# All rights reserved - Do Not Redistribute
#

directory "/root/.composer" do
  mode '0755'
  action :create
end
template "/root/.composer/auth.json" do
  source "auth.json.erb"
  mode '0600'
  variables ({
    :token => node['nt-deploy']['github']
  })
end

mysql2_chef_gem 'default' do
  action :install
end

directory '/mnt/data-store/NTMicrosites' do
  owner 'apache'
  group 'apache'
  mode  '0755'
  action :create
end

package 'unzip'

execute 'unzip_code' do
  cwd     '/mnt/data-store/NTMicrosites'
  command 'unzip -q -o v2.0.2.zip'
  action  :nothing
end

include_recipe 's3_file::dependencies'

s3_file "/mnt/data-store/NTMicrosites/v2.0.2.zip" do
    remote_path "/NTOtherDrupal/v2.0.2.zip"
    bucket "live-codeartifacts"
    s3_url "https://s3-eu-west-1.amazonaws.com/live-codeartifacts"
    mode "0644"
    action :create
    notifies :run, 'execute[unzip_code]', :immediately
    not_if { ::File.exists?("/mnt/data-store/NTMicrosites/v2.0.2.zip") }
end

keys = data_bag('ntother_live')

nt_deploy "linburyprize" do
    site_label 'NTMicrosites'
    use_bundle true
    site_dns 'linburyprize.cms.nationaltheatre.org.uk'
    vhost 'linburyprize'
    db_user 'linburyprize'
    db_pwd data_bag_item('ntother_live', 'linburyprize')['pwd']
    cache_prefix 'lby_'
    salt data_bag_item('ntother_live', 'linburyprize')['salt']
    cron_key data_bag_item('ntother_live', 'linburyprize')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    site_path '/mnt/data-store/'
    aws_bucket 'linbury-prize'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "newviews" do
    site_label 'NTMicrosites'
    use_bundle true
    site_dns 'new-views.cms.nationaltheatre.org.uk'
    vhost 'newviews'
    db_user 'newviews'
    db_pwd data_bag_item('ntother_live', 'newviews')['pwd']
    cache_prefix 'nv_'
    salt data_bag_item('ntother_live', 'newviews')['salt']
    cron_key data_bag_item('ntother_live', 'newviews')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    site_path '/mnt/data-store/'
    aws_bucket 'live-newviews'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "ntfuture" do
    site_label 'NTMicrosites'
    use_bundle true
    site_dns 'ntfuture.cms.nationaltheatre.org.uk'
    vhost 'NT-Future'
    db_user 'ntfuture'
    db_pwd data_bag_item('ntother_live', 'ntfuture')['pwd']
    cache_prefix 'ntf_'
    salt data_bag_item('ntother_live', 'ntfuture')['salt']
    cron_key data_bag_item('ntother_live', 'ntfuture')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    site_path '/mnt/data-store/'
    aws_bucket 'live-ntfuture'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "allabouttheatre" do
    site_label 'NTMicrosites'
    use_bundle true
    site_dns 'allabouttheatre.cms.nationaltheatre.org.uk'
    vhost 'allabouttheatre'
    db_user 'allabouttheatre'
    db_pwd data_bag_item('ntother_live', 'allabouttheatre')['pwd']
    cache_prefix 'abt_'
    salt data_bag_item('ntother_live', 'allabouttheatre')['salt']
    cron_key data_bag_item('ntother_live', 'allabouttheatre')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    site_path '/mnt/data-store/'
    aws_bucket 'live-allabouttheatre'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

