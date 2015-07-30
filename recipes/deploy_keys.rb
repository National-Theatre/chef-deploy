#
# Cookbook Name:: nt-deploy
# Recipe:: deploy_keys
#
# Copyright 2015, National Theatre
#
# All rights reserved - Do Not Redistribute
#

keys = data_bag(node['nt-deploy']['grid_bag'])

keys.each do |site|
  key = data_bag_item('deploy_keys', site)['key']
  template "#{node['nt-deploy']['ssh_dir']}/#{site}" do
    source "rsa_id.erb"
    mode '0400'
    variables :key => key
  end
end

sites = {}
node['nt-deploy']['sites'].each do |site, data|
  puts site
  puts node['nt-deploy']['sites'][site]
  sites[site] = {}
  sites[site]['repo_key'] = node['nt-deploy']['sites'][site]['repo_key']
  sites[site]['repo_path'] = node['nt-deploy']['sites'][site]['repo_path']
  sites[site]['repo_site'] = node['nt-deploy']['sites'][site].fetch('repo_site', 'github.com')
  sites[site]['repo_user'] = node['nt-deploy']['sites'][site].fetch('repo_user', 'git')
end


template "#{node['nt-deploy']['ssh_dir']}/config" do
  source "config.erb"
  variables ({:sites => sites})
end
