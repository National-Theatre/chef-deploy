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
    aws_bucket 'linbury-prize-staging'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "stg_newviews" do
    site_label 'NTMicrosites'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'master'
    site_dns 'new-views.ntstaging.org'
    vhost 'newviews'
    db_user 'newviews'
    db_pwd data_bag_item('drupal_stg', 'newviews')['pwd']
    cache_prefix 'stg_nv_'
    salt data_bag_item('drupal_stg', 'newviews')['salt']
    cron_key data_bag_item('drupal_stg', 'newviews')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'stg-newviews'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "stg_ntfuture" do
    site_label 'NTMicrosites'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'master'
    site_dns 'ntfuture.ntstaging.org'
    vhost 'NT-Future'
    db_user 'ntfuture'
    db_pwd data_bag_item('drupal_stg', 'ntfuture')['pwd']
    cache_prefix 'stg_ntf_'
    salt data_bag_item('drupal_stg', 'ntfuture')['salt']
    cron_key data_bag_item('drupal_stg', 'ntfuture')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'stg-ntfuture'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "stg_allabouttheatre" do
    site_label 'NTMicrosites'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'master'
    site_dns 'allabouttheatre.ntstaging.org'
    vhost 'allabouttheatre'
    db_user 'allabouttheatre'
    db_pwd data_bag_item('drupal_stg', 'allabouttheatre')['pwd']
    cache_prefix 'stg_aat_'
    salt data_bag_item('drupal_stg', 'allabouttheatre')['salt']
    cron_key data_bag_item('drupal_stg', 'allabouttheatre')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'stg-allabouttheatre'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "stg_catering" do
    site_label 'NTMicrosites'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'master'
    domain true
    site_dns 'catering.ntstaging.org'
    vhost 'default'
    db_user 'catering'
    db_pwd data_bag_item('drupal_stg', 'catering')['pwd']
    cache_prefix 'stg_cat_'
    salt data_bag_item('drupal_stg', 'catering')['salt']
    cron_key data_bag_item('drupal_stg', 'catering')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'stg-catering'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end
