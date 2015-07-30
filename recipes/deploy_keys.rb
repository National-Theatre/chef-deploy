#
# Cookbook Name:: nt-deploy
# Recipe:: deploy_keys
#
# Copyright 2015, National Theatre
#
# All rights reserved - Do Not Redistribute
#

keys = data_bag('deploy_keys')

keys.each do |site|
  key = data_bag_item('deploy_keys', site)
  template "~/.ssh/#{site}" do
    source "rsa_id.erb"
    mode '0400'
    variables {:key => key}
  end
end

sites = node['nt-deploy']['sites']

sites.each_with_index do |site, data|
  sites[site]['repo_site'] ||= 'github.com'
  sites[site]['repo_user'] ||= 'git'
end


template '~/.ssh/config' do
  source "config.erb"
  variables @sites => sites
end