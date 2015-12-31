#
# Cookbook Name:: nt-deploy
# Recipe:: drupal_deploy
#
# Copyright 2015, National Theatre
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


drupal = {}
node['nt-deploy']['sites'].each do |site, data|
  drupal[site] = {}
  drupal[site]['repo_path']   = node['nt-deploy']['sites'][site]['repo_path']
  drupal[site]['repo_tag']    = node['nt-deploy']['sites'][site].fetch('repo_tag', false)
  drupal[site]['repo_branch'] = node['nt-deploy']['sites'][site].fetch('repo_branch', 'develop')
  drupal[site]['site_path']   = node['nt-deploy']['sites'][site].fetch('site_path', '/var/www')
  drupal[site]['repo_user']   = node['nt-deploy']['sites'][site].fetch('repo_user', 'git')
  drupal[site]['site_type']   = node['nt-deploy']['sites'][site].fetch('site_type', 'drupal')
  site_label                  = node['nt-deploy']['sites'][site].fetch('site_label', site)
  execute 'clone_site' do
    command "git clone #{drupal[site]['repo_user']}@#{site}:#{drupal[site]['repo_path']} #{drupal[site]['site_path']}/#{site_label}"
    not_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}") || drupal[site]['site_type'] != "drupal" }
  end
  
  execute 'checkout_branch' do
    cwd "#{drupal[site]['site_path']}/#{site_label}"
    command "git checkout -b #{drupal[site]['repo_branch']} origin/#{drupal[site]['repo_branch']}; git pull"
    only_if { drupal[site]['site_type'] == "drupal" && drupal[site]['repo_tag'] == false }
  end
  
  execute 'checkout_branch' do
    cwd "#{drupal[site]['site_path']}/#{site_label}"
    command "git fetch origin; git checkout -b #{drupal[site]['repo_tag']} tags/#{drupal[site]['repo_tag']}"
    only_if { drupal[site]['repo_tag'] }
  end
  
  drupal[site]['vhost'] = node['nt-deploy']['sites'][site].fetch('vhost', 'default')
  drupal[site]['db_name'] = node['nt-deploy']['sites'][site].fetch('db_name', "drupal_#{site}")
  drupal[site]['db_user'] = node['nt-deploy']['sites'][site].fetch('db_user', site)
  drupal[site]['db_pwd'] = node['nt-deploy']['sites'][site].fetch('db_pwd', site)
  drupal[site]['db_host'] = node['nt-deploy']['sites'][site].fetch('db_host', node['nt-deploy']['default']['db_host'])
  drupal[site]['elb'] = node['nt-deploy']['sites'][site].fetch('elb', node['nt-deploy']['default']['elb'])
  drupal[site]['salt'] = node['nt-deploy']['sites'][site].fetch('salt', '')
  drupal[site]['cache_prefix'] = node['nt-deploy']['sites'][site].fetch('cache_prefix', "#{site}_")
  drupal[site]['sites_caches'] = node['nt-deploy']['sites'][site].fetch('sites_caches', [])
  
  drupal[site]['site_dns'] = node['nt-deploy']['sites'][site].fetch('site_dns', 'www.example.net')
  drupal[site]['cron_key'] = node['nt-deploy']['sites'][site].fetch('cron_key', 'cron-key')
  
  drupal[site]['memcache_host'] = node['nt-deploy']['sites'][site].fetch('memcache_host', node['nt-deploy']['default']['memcache'])
  drupal[site]['redis_host'] = node['nt-deploy']['sites'][site].fetch('redis_host', node['nt-deploy']['default']['redis'])
  
  case node['nt-deploy']['sites'][site].fetch('cache_type', 'none')
  when 'MemCacheDrupal'
    cache_settings = <<-EOS
$conf['memcache_key_prefix'] = '#{drupal[site]['cache_prefix']}';
$conf['cache_default_class'] = 'MemCacheDrupal';
$conf['memcache_servers'] = array(
    '#{drupal[site]['memcache_host']}' => 'default',
);
$conf['page_cache_without_database'] = TRUE;
$conf['page_cache_invoke_hooks'] = FALSE;
    EOS
  when 'MemcacheStorage'
    cache_settings = <<-EOS
$conf['memcache_extension'] = 'Memcached';
$conf['memcache_storage_key_prefix'] = '#{drupal[site]['cache_prefix']}';
$conf['memcache_storage_persistent_connection'] = TRUE;
$conf['lock_inc'] = 'sites/all/modules/contrib/memcache_storage/includes/lock.inc';
$conf['session_inc'] = 'sites/all/modules/contrib/memcache_storage/includes/session.inc';
$conf['cache_backends'][] = 'sites/all/modules/contrib/memcache_storage/memcache_storage.inc';
$conf['cache_default_class'] = 'MemcacheStorage';
$conf['cache_backends'][] = 'sites/all/modules/contrib/memcache_storage/memcache_storage.page_cache.inc';
$conf['cache_class_cache_page'] = 'MemcacheStoragePageCache';
$conf['memcache_servers'] = array(
    '#{drupal[site]['memcache_host']}' => 'default',
);
$conf['page_cache_without_database'] = TRUE;
$conf['page_cache_invoke_hooks'] = FALSE;
    EOS
  when 'Redis_Cache'
    cache_settings = <<-EOS
$conf['redis_client_interface'] = 'PhpRedis';
$conf['cache_default_class'] = 'Redis_Cache';
$conf['redis_client_host'] = '#{drupal[site]['redis_host']}';
$conf['lock_inc'] = 'sites/all/modules/contrib/redis/redis.lock.inc';
$conf['path_inc'] = 'sites/all/modules/contrib/redis/redis.path.inc';
$conf['page_cache_without_database'] = TRUE;
$conf['page_cache_invoke_hooks'] = FALSE;
    EOS
  else
    cache_settings = ''
  end
  
  directory "#{drupal[site]['site_path']}/#{site_label}/drupal/sites/#{drupal[site]['vhost']}" do
    mode '0755'
    action :create
    recursive true
    only_if { drupal[site]['site_type'] == "drupal" }
  end
  directory "#{drupal[site]['site_path']}/#{site_label}/drupal/sites/#{drupal[site]['vhost']}/files" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
    only_if { drupal[site]['site_type'] == "drupal" }
  end
  execute 'drupal_chcon' do
    command "chcon -R -t httpd_sys_rw_content_t #{drupal[site]['site_path']}/#{site_label}/drupal"
    not_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/drupal/sites/#{drupal[site]['vhost']}/settings.php") || drupal[site]['site_type'] != "drupal" }
  end
  execute 'drupal_files_chcon' do
    command "chcon -R -t httpd_sys_rw_content_t #{drupal[site]['site_path']}/#{site_label}/drupal/sites/#{drupal[site]['vhost']}/files"
    only_if { drupal[site]['site_type'] == "drupal" }
  end
  
  directory "/media/ephemeral0/tmp/#{site}" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
    only_if { drupal[site]['site_type'] == "drupal" }
  end
  execute 'tmp_chcon' do
    command "chcon -R -t httpd_sys_rw_content_t media/ephemeral0/tmp/#{site}"
    not_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/drupal/sites/#{drupal[site]['vhost']}/settings.php") || drupal[site]['site_type'] != "drupal" }
  end
  directory "/media/ephemeral0/private/#{site}" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
    only_if { drupal[site]['site_type'] == "drupal" }
  end
  execute 'tmp_chcon' do
    command "chcon -R -t httpd_sys_rw_content_t media/ephemeral0/private/#{site}"
    not_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/drupal/sites/#{drupal[site]['vhost']}/settings.php") || drupal[site]['site_type'] != "drupal" }
  end

  template "#{drupal[site]['site_path']}/#{site_label}/drupal/sites/#{drupal[site]['vhost']}/settings.php" do
    source "settings.php.erb"
    mode '0440'
    owner 'apache'
    group 'apache'
    variables ({
      :db_name => drupal[site]['db_name'],
      :db_user => drupal[site]['db_user'],
      :db_pwd => drupal[site]['db_pwd'],
      :db_host => drupal[site]['db_host'],
      :site_name => site,
      :salt => drupal[site]['salt'],
      :elb => drupal[site]['elb'],
      :cache_prefix => drupal[site]['cache_prefix'],
      :sites_caches => drupal[site]['sites_caches'],
      :cache_settings => cache_settings,
      :composer_json_dir => "#{drupal[site]['site_path']}/#{site_label}/drupal/sites/#{drupal[site]['vhost']}/files/composer",
      :composer_vendor_dir => 'composer_vendor_dir'
    })
    only_if { drupal[site]['site_type'] == "drupal" }
  end
  if File.exists?("#{drupal[site]['site_path']}/#{site_label}/tests/composer.phar")
    execute 'run_composer' do
      cwd "#{drupal[site]['site_path']}/#{site_label}/tests"
      command 'php composer.phar install --no-dev -o'
      not_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/tests/composer.lock") || drupal[site]['site_type'] != "drupal" }
    end
  end
  execute 'update_composer' do
    cwd "#{drupal[site]['site_path']}/#{site_label}/tests"
    command 'php composer.phar update --no-dev -o'
    only_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/tests/composer.lock") && drupal[site]['site_type'] == "drupal" }
  end
  execute 'drush_composer_setup' do
    cwd "#{drupal[site]['site_path']}/#{site_label}/drupal"
    command <<-EOM
../tests/bin/drush -y en composer_manager --uri=http://#{drupal[site]['site_dns']}
../tests/bin/drush composer-json-rebuild --uri=http://#{drupal[site]['site_dns']}
    EOM
    only_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/tests/bin/drush") && drupal[site]['site_type'] == "drupal" }
  end
  
  directory "#{drupal[site]['site_path']}/#{site_label}/drupal/sites/all/libraries/composer" do
    mode '0755'
    action :create
    recursive true
    only_if { drupal[site]['site_type'] == "drupal" }
  end
  execute 'drush_composer' do
    cwd "#{drupal[site]['site_path']}/#{site_label}/drupal/sites/all/libraries/composer"
    command <<-EOM
    php #{drupal[site]['site_path']}/#{site_label}/tests/composer.phar install --no-dev -o
    EOM
    environment ({
      'COMPOSER_VENDOR_DIR' => "#{drupal[site]['site_path']}/#{site_label}/drupal/sites/all/libraries/composer",
      'COMPOSER' => "#{drupal[site]['site_path']}/#{site_label}/drupal/sites/#{drupal[site]['vhost']}/files/composer/composer.json"
    })
    only_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/tests/composer.phar") && ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/drupal/sites/#{drupal[site]['vhost']}/files/composer/composer.json") && drupal[site]['site_type'] == "drupal" }
  end
  cron_d "hourly_cron_#{site}" do
    minute  0
    command "curl -o /dev/null -sS http://#{drupal[site]['site_dns']}/cron.php?cron_key=#{drupal[site]['cron_key']}"
    user    'apache'
    only_if { drupal[site]['site_type'] == "drupal" }
  end
  hostsfile_entry '127.0.0.1' do
    hostname  drupal[site]['site_dns']
    unique    true
    comment   'Append by Recipe drupal_deploy'
    action    :append
  end

end
