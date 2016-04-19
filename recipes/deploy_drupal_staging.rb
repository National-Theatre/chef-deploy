#
# Cookbook Name:: nt-deploy
# Recipe:: deploy_drupal_staging
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

keys = data_bag('drupal_stg')

nt_deploy "stg_linburyprize" do
    site_label 'NTMicrosites'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'master'
    site_dns 'linburyprize.cms.ntstaging.org'
    vhost 'linburyprize'
    db_user 'linburyprize'
    db_pwd data_bag_item('drupal_stg', 'linburyprize')['pwd']
    cache_prefix 'stg_lby_'
    salt data_bag_item('drupal_stg', 'linburyprize')['salt']
    cron_key data_bag_item('drupal_stg', 'linburyprize')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
end

nt_deploy "stg_newviews" do
    site_label 'NTMicrosites'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'master'
    site_dns 'new-views.ntstaging.org'
    vhost 'newviews'
    db_user 'newviews'
    db_pwd data_bag_item('drupal_stg', 'newviews')['pwd']
    cache_prefix 'nv_'
    salt data_bag_item('drupal_stg', 'newviews')['salt']
    cron_key data_bag_item('drupal_stg', 'newviews')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
end
