
action :create do
  site = new_resource.site
  drupal = {}
  drupal[site] = {}
  drupal[site]['repo_path']   = new_resource.repo_path
  drupal[site]['repo_tag']    = new_resource.repo_tag
  drupal[site]['repo_branch'] = new_resource.repo_branch
  drupal[site]['site_path']   = new_resource.site_path
  drupal[site]['repo_user']   = new_resource.repo_user
  drupal[site]['site_type']   = new_resource.site_type
  site_label                  = new_resource.site_label.nil? ? site : new_resource.site_label
  unless new_resource.use_bundle
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
  end
  
  drupal[site]['vhost'] = new_resource.vhost
  drupal[site]['db_name'] = new_resource.db_name.nil? ? "drupal_#{site}" : new_resource.db_name
  drupal[site]['db_user'] = new_resource.db_user.nil? ? site : new_resource.db_user
  drupal[site]['db_pwd'] = new_resource.db_pwd.nil? ? site : new_resource.db_pwd
  drupal[site]['db_host'] = new_resource.db_host.nil? ? node['nt-deploy']['default']['db_host'] : new_resource.db_host
  drupal[site]['elb'] = new_resource.elb.nil? ? node['nt-deploy']['default']['elb'] : new_resource.elb
  drupal[site]['salt'] = new_resource.salt
  drupal[site]['cache_prefix'] = new_resource.cache_prefix.nil? ? "#{site}_" : new_resource.cache_prefix
  drupal[site]['sites_caches'] = new_resource.sites_caches
  
  drupal[site]['site_dns'] = new_resource.site_dns
  drupal[site]['cron_key'] = new_resource.cron_key
  
  drupal[site]['memcache_host'] = new_resource.memcache_host.nil? ? node['nt-deploy']['default']['memcache'] : new_resource.memcache_host
  drupal[site]['redis_host'] = new_resource.redis_host.nil? ? node['nt-deploy']['default']['redis'] : new_resource.redis_host
  
  mysql_database drupal[site]['db_name'] do
    connection(
      :host     => drupal[site]['db_host'],
      :username => node['nt-deploy']['mysql']['initial_user'],
      :password => node['nt-deploy']['mysql']['initial_root_password']
    )
    action :create
  end
  
  mysql_database_user drupal[site]['db_user'] do
    connection(
      :host     => drupal[site]['db_host'],
      :username => node['nt-deploy']['mysql']['initial_user'],
      :password => node['nt-deploy']['mysql']['initial_root_password']
    )
    password      drupal[site]['db_pwd']
    database_name drupal[site]['db_name']
    host          '%'
    action [:create, :grant]
  end
  
  case new_resource.cache_type
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
  
  directory "#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/#{drupal[site]['vhost']}" do
    mode '0755'
    action :create
    recursive true
  end
  directory "#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/#{drupal[site]['vhost']}/files" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
  end
  directory "#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/#{drupal[site]['vhost']}/files/composer" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
  end
  execute 'copy_composer' do
    command "cp #{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/#{drupal[site]['vhost']}/composer.json #{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/#{drupal[site]['vhost']}/files/composer/composer.json"
      only_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/#{drupal[site]['vhost']}/composer.json")}
      not_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/#{drupal[site]['vhost']}/files/composer/composer.json")}
  end
  
  execute 'drupal_chcon' do
    command "chcon -R -t httpd_sys_rw_content_t #{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}"
    not_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/#{drupal[site]['vhost']}/settings.php") || drupal[site]['site_type'] != "drupal" }
  end
  
  selinux_policy_fcontext "#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/#{drupal[site]['vhost']}/files(/.*)?" do
    secontext 'httpd_sys_rw_content_t'
  end
  
  directory "/media/ephemeral0/tmp/#{site}" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
    only_if { drupal[site]['site_type'] == "drupal" }
  end
  selinux_policy_fcontext "/media/ephemeral0/tmp/#{site}(/.*)?" do
    secontext 'httpd_sys_rw_content_t'
  end

  directory "/media/ephemeral0/private/#{site}" do
    owner 'apache'
    group 'apache'
    mode '0755'
    action :create
    recursive true
  end
  selinux_policy_fcontext "/media/ephemeral0/private/#{site}(/.*)?" do
    secontext 'httpd_sys_rw_content_t'
  end

  template "#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/#{drupal[site]['vhost']}/settings.php" do
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
      :composer_json_dir => "#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/#{drupal[site]['vhost']}/files/composer",
      :composer_vendor_dir => 'sites/all/libraries/composer',
      :amazons3_bucket => new_resource.aws_bucket,
      :amazons3_key    => new_resource.aws_key,
      :amazons3_secret => new_resource.aws_secret
    })
  end
  if ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/tests/composer.phar")
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
  
  directory "#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/all/libraries/composer" do
    mode '0755'
    action :create
    recursive true
  end
  execute 'drush_composer' do
    cwd "#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/all/libraries/composer"
    command <<-EOM
    php #{drupal[site]['site_path']}/#{site_label}/tests/composer.phar install --no-dev -o
    EOM
    environment ({
      'COMPOSER_VENDOR_DIR' => "#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/all/libraries/composer",
      'COMPOSER' => "#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/all/libraries/composer.json"
    })
    only_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/tests/composer.phar") && ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/all/libraries/composer.json") && drupal[site]['site_type'] == "drupal" }
    not_if { ::File.exists?("#{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}/sites/all/libraries/composer/autoload.php") }
  end
  cron_d "hourly_cron_#{site}" do
    minute  0
    command "curl -o /dev/null -sS http://#{drupal[site]['site_dns']}/cron.php?cron_key=#{drupal[site]['cron_key']}"
    user    'apache'
  end
  cron_d "hourly_drush_cron_#{site}" do
    minute  30
    command "cd #{drupal[site]['site_path']}/#{site_label}/#{new_resource.drupal_root}; /usr/bin/drush --uri=http://#{drupal[site]['site_dns']} cron"
    user    'apache'
  end
  hostsfile_entry '127.0.0.1' do
    hostname  drupal[site]['site_dns']
    unique    true
    comment   'Append by Recipe drupal_deploy'
    action    :append
  end
end
