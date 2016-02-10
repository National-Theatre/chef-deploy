#
# Cookbook Name:: nt-deploy
# Recipe:: magento_deploy
#
# Copyright 2015, National Theatre
#
# All rights reserved - Do Not Redistribute
#

service "httpd" do
  action :nothing
end

selinux_policy_boolean 'httpd_can_network_connect' do
    value true
    notifies :restart,'service[httpd]', :delayed
end

magento = {}
node['nt-deploy']['sites'].each do |site, data|
  magento[site] = {}
  magento[site]['repo_path'] = node['nt-deploy']['sites'][site]['repo_path']
  magento[site]['repo_tag'] = node['nt-deploy']['sites'][site].fetch('repo_tag', false)
  magento[site]['repo_branch'] = node['nt-deploy']['sites'][site].fetch('repo_branch', 'develop')
  magento[site]['site_path'] = node['nt-deploy']['sites'][site].fetch('site_path', '/var/www')
  magento[site]['repo_user'] = node['nt-deploy']['sites'][site].fetch('repo_user', 'git')
  magento[site]['site_type'] = node['nt-deploy']['sites'][site].fetch('site_type', 'magento')
  
  execute 'clear_repo_path' do
    command "rm -rf #{magento[site]['repo_path']}"
    only_if { ::File.exists?("#{magento[site]['repo_path']}/magento/index.html")}
  end
  
  execute 'clone_site' do
    command "git clone #{magento[site]['repo_user']}@#{site}:#{magento[site]['repo_path']} #{magento[site]['site_path']}/#{site}"
    not_if { ::File.exists?("#{magento[site]['site_path']}/#{site}") || magento[site]['site_type'] != "magento" }
  end
  
  execute 'checkout_branch' do
    cwd "#{magento[site]['site_path']}/#{site}"
    command "git checkout -b #{magento[site]['repo_branch']} origin/#{magento[site]['repo_branch']}; git pull"
    only_if { magento[site]['site_type'] == "magento" && magento[site]['repo_tag'] == false }
  end
  
  execute 'checkout_branch' do
    cwd "#{magento[site]['site_path']}/#{site}"
    command "git fetch origin; git checkout -b #{magento[site]['repo_tag']} tags/#{magento[site]['repo_tag']}"
    only_if { magento[site]['repo_tag'] }
  end
  
  magento[site]['vhost'] = node['nt-deploy']['sites'][site].fetch('vhost', 'default')
  magento[site]['db_name'] = node['nt-deploy']['sites'][site].fetch('db_name', "magento_#{site}")
  magento[site]['db_user'] = node['nt-deploy']['sites'][site].fetch('db_user', site)
  magento[site]['db_pwd'] = node['nt-deploy']['sites'][site].fetch('db_pwd', site)
  magento[site]['db_host'] = node['nt-deploy']['sites'][site].fetch('db_host', node['nt-deploy']['default']['db_host'])
  magento[site]['elb'] = node['nt-deploy']['sites'][site].fetch('elb', node['nt-deploy']['default']['elb'])
  magento[site]['salt'] = node['nt-deploy']['sites'][site].fetch('salt', '')
  magento[site]['cache_prefix'] = node['nt-deploy']['sites'][site].fetch('cache_prefix', "#{site}_")
  magento[site]['sites_caches'] = node['nt-deploy']['sites'][site].fetch('sites_caches', [])
  
  magento[site]['site_dns'] = node['nt-deploy']['sites'][site].fetch('site_dns', 'www.example.net')
  magento[site]['admin_url'] = node['nt-deploy']['sites'][site].fetch('admin_url', 'admin')
  magento[site]['cron_key'] = node['nt-deploy']['sites'][site].fetch('cron_key', 'cron-key')
  
  directory "/media/ephemeral0/tmp/#{site}" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
  end
  
  execute 'tmp_chcon' do
    command "chcon -R -t httpd_sys_rw_content_t /media/ephemeral0/tmp/#{site}"
  end
  
  execute 'magento_chown' do
    command "chown -R apache:apache #{magento[site]['site_path']}/#{site}"
  end
  
  selinux_policy_fcontext "#{magento[site]['site_path']}/#{site}/magento(/.*)?" do
    secontext 'httpd_sys_content_t'
  end
  
  selinux_policy_fcontext "#{magento[site]['site_path']}/#{site}/magento(/.*)\.php?" do
    secontext 'httpd_user_script_exec_t'
  end
  
  selinux_policy_fcontext "#{magento[site]['site_path']}/#{site}/magento/media(/.*)?" do
    secontext 'httpd_sys_rw_content_t'
  end
  
  selinux_policy_fcontext "#{magento[site]['site_path']}/#{site}/magento/var(/.*)?" do
    secontext 'httpd_sys_rw_content_t'
  end
  
  template "#{magento[site]['site_path']}/#{site}/magento/app/etc/local.xml" do
    source "local.xml.erb"
    mode '0440'
    owner 'apache'
    group 'apache'
    variables ({
      :db_name   => magento[site]['db_name'],
      :db_user   => magento[site]['db_user'],
      :db_pwd    => magento[site]['db_pwd'],
      :db_host   => magento[site]['db_host'],
      :salt      => magento[site]['salt'],
      :admin_url => magento[site]['admin_url']
    })
    only_if { magento[site]['site_type'] == "magento" }
  end

end
