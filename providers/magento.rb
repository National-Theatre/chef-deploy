
action :create do
  magento = {}
  site = new_resource.site
  magento[site] = {}
  magento[site]['repo_path']   = new_resource.repo_path
  magento[site]['repo_tag']    = new_resource.repo_tag
  magento[site]['repo_branch'] = new_resource.repo_branch
  magento[site]['site_path']   = new_resource.site_path
  magento[site]['repo_user']   = new_resource.repo_user
  magento[site]['site_type']   = new_resource.site_type
  site_label                   = new_resource.site_label.nil? ? site : new_resource.site_label
  
  unless new_resource.use_bundle
    execute 'clear_repo_path' do
        command "rm -rf #{magento[site]['site_path']}/#{site}"
        only_if { ::File.exists?("#{magento[site]['site_path']}/#{site}/magento/index.html")}
        not_if {::File.exists?("#{magento[site]['site_path']}/#{site}/.git")}
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
  end
  
  magento[site]['db_name'] = new_resource.db_name.nil? ? "magento_#{site}" : new_resource.db_name
  magento[site]['db_user'] = new_resource.db_user.nil? ? site : new_resource.db_user
  magento[site]['db_pwd']  = new_resource.db_pwd.nil? ? site : new_resource.db_pwd
  magento[site]['db_host'] = new_resource.db_host.nil? ? node['nt-deploy']['default']['db_host'] : new_resource.db_host
  magento[site]['elb']     = new_resource.elb.nil? ? node['nt-deploy']['default']['elb'] : new_resource.elb
  magento[site]['salt']    = new_resource.salt
  magento[site]['cache_prefix'] = new_resource.cache_prefix.nil? ? "#{site}_" : new_resource.cache_prefix
  magento[site]['sites_caches'] = new_resource.sites_caches
  
  magento[site]['site_dns'] = new_resource.site_dns
  magento[site]['admin_url'] = new_resource.admin_url
  magento[site]['cron_key'] = new_resource.cron_key
  
  directory "/media/ephemeral0/tmp/#{site}" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
  end
  
  selinux_policy_fcontext "/media/ephemeral0/tmp/#{site}(/.*)?" do
    secontext 'httpd_sys_rw_content_t'
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
  
  selinux_policy_fcontext "#{magento[site]['site_path']}/#{site}/magento/includes(/.*)?" do
    secontext 'httpd_sys_rw_content_t'
  end
  
  selinux_policy_fcontext "#{magento[site]['site_path']}/#{site}/magento/includes/config\.php?" do
    secontext 'httpd_sys_rw_content_t'
  end
  
  selinux_policy_fcontext "#{magento[site]['site_path']}/#{site}/magento/var(/.*)?" do
    secontext 'httpd_sys_rw_content_t'
  end
  
  selinux_policy_fcontext "#{magento[site]['site_path']}/#{site}/magento/xmlfile.xml" do
    secontext 'httpd_sys_rw_content_t'
  end
  
  %w{app dev downloader downloaderntmgt errors includes js lib newslettersucess pkginfo shell skin var}.each do |folder|
    directory "#{magento[site]['site_path']}/#{site}/magento/#{folder}" do
      owner 'apache'
      group 'apache'
      mode '0755'
      recursive true
      action :create
    end
  end
  Dir.foreach("#{magento[site]['site_path']}/#{site}/magento") do |item|
    next if item == '.' or item == '..' or File.directory?("#{magento[site]['site_path']}/#{site}/magento/#{item}")
    file "#{magento[site]['site_path']}/#{site}/magento/#{item}" do
      mode '0644'
      owner 'apache'
      group 'apache'
    end
  end
  
  file "#{magento[site]['site_path']}/#{site}/magento/includes/config.php" do
    mode '0664'
    owner 'apache'
    group 'apache'
  end
  
  %w{export import importexport package report}.each do |folder|
    directory "#{magento[site]['site_path']}/#{site}/magento/var/#{folder}" do
      owner 'apache'
      group 'apache'
      mode '0755'
      recursive true
      action :create
    end
  end
  
  template "#{magento[site]['site_path']}/#{site}/magento/app/etc/local.xml" do
    source "local.xml.erb"
    mode '0440'
    owner 'apache'
    group 'ec2-user'
    variables ({
      :db_name   => magento[site]['db_name'],
      :db_user   => magento[site]['db_user'],
      :db_pwd    => magento[site]['db_pwd'],
      :db_host   => magento[site]['db_host'],
      :salt      => magento[site]['salt'],
      :admin_url => magento[site]['admin_url']
    })
  end
  
  cron_d "magento_cron_sh_#{site}" do
    command "/bin/sh #{magento[site]['site_path']}/#{site}/magento/cron.sh"
    user    'ec2-user'
  end
end
