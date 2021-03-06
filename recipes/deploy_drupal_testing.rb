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

keys = data_bag('drupal_dev')

nt_deploy "dev_linburyprize" do
    site_label 'NTMicrositesDev'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'staging'
    site_dns 'linburyprize.nttest.org'
    vhost 'linburyprize'
    db_user 'linburyprize'
    db_pwd data_bag_item('drupal_dev', 'linburyprize')['pwd']
    cache_prefix 'dev_lby_'
    salt data_bag_item('drupal_dev', 'linburyprize')['salt']
    cron_key data_bag_item('drupal_dev', 'linburyprize')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'test-linburyprize'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "dev_newviews" do
    site_label 'NTMicrositesDev'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'staging'
    site_dns 'new-views.nttest.org'
    vhost 'newviews'
    db_user 'newviews'
    db_pwd data_bag_item('drupal_dev', 'newviews')['pwd']
    cache_prefix 'dev_nv_'
    salt data_bag_item('drupal_dev', 'newviews')['salt']
    cron_key data_bag_item('drupal_dev', 'newviews')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'test-newviews'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "dev_ntfuture" do
    site_label 'NTMicrositesDev'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'staging'
    site_dns 'ntfuture.nttest.org'
    vhost 'NT-Future'
    db_user 'ntfuture'
    db_pwd data_bag_item('drupal_dev', 'ntfuture')['pwd']
    cache_prefix 'dev_ntf_'
    salt data_bag_item('drupal_dev', 'ntfuture')['salt']
    cron_key data_bag_item('drupal_dev', 'ntfuture')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'test-ntfuture'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "dev_allabouttheatre" do
    site_label 'NTMicrositesDev'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'staging'
    site_dns 'allabouttheatre.nttest.org'
    vhost 'allabouttheatre'
    db_user 'allabouttheatre'
    db_pwd data_bag_item('drupal_dev', 'allabouttheatre')['pwd']
    cache_prefix 'dev_aat_'
    salt data_bag_item('drupal_dev', 'allabouttheatre')['salt']
    cron_key data_bag_item('drupal_dev', 'allabouttheatre')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'test-allabouttheatre'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "dev_catering" do
    site_label 'NTMicrositesDev'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'staging'
    domain true
    site_dns 'catering.nttest.org'
    vhost 'default'
    db_user 'catering'
    db_pwd data_bag_item('drupal_dev', 'catering')['pwd']
    cache_prefix 'dev_cat_'
    salt data_bag_item('drupal_dev', 'catering')['salt']
    cron_key data_bag_item('drupal_dev', 'catering')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'test-catering'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "dev_thedeck" do
    site_label 'NTMicrositesDev'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'staging'
    site_dns 'thedeck.nttest.org'
    vhost 'thedeck'
    db_user 'thedeck'
    db_pwd data_bag_item('drupal_dev', 'thedeck')['pwd']
    cache_prefix 'dev_tdk_'
    salt data_bag_item('drupal_dev', 'thedeck')['salt']
    cron_key data_bag_item('drupal_dev', 'thedeck')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'test-thedeck'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "dev_connections" do
    site_label 'NTMicrositesDev'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'staging'
    site_dns 'connections.nttest.org'
    vhost 'connections'
    db_user 'dev_connections'
    db_pwd data_bag_item('drupal_dev', 'connections')['pwd']
    cache_prefix 'dev_cnt_'
    salt data_bag_item('drupal_dev', 'connections')['salt']
    cron_key data_bag_item('drupal_dev', 'connections')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'test-connections'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end

nt_deploy "dev_ntjobs" do
    site_label 'NTMicrositesDev'
    repo_path 'National-Theatre/NT-Web-Hosting.git'
    repo_branch 'staging'
    site_dns 'ntjobs.nttest.org'
    vhost 'ntjobs'
    db_user 'dev_ntjobs'
    db_pwd data_bag_item('drupal_dev', 'ntjobs')['pwd']
    cache_prefix 'dev_ntj_'
    salt data_bag_item('drupal_dev', 'ntjobs')['salt']
    cron_key data_bag_item('drupal_dev', 'ntjobs')['cron']
    cache_type 'Redis_Cache'
    sites_caches ['sites/all/modules/contrib/redis/redis.autoload.inc']
    aws_bucket 'test-ntjobs'
    aws_key node['nt-deploy']['default']['aws_key']
    aws_secret node['nt-deploy']['default']['aws_secret']
end
