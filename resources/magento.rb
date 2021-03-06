default_action(:create)

attribute :site, :kind_of => String, :name_attribute => true
attribute :repo_path, :kind_of => String
attribute :repo_tag, :kind_of => [TrueClass, FalseClass], :default => false
attribute :use_bundle, :kind_of => [TrueClass, FalseClass], :default => false
attribute :repo_branch, :kind_of => String, :default => 'develop'
attribute :site_path, :kind_of => String, :default => '/var/www'
attribute :repo_user, :kind_of => String, :default => 'git'
attribute :site_type, :kind_of => String, :default => 'magento'
attribute :site_label, :kind_of => String, :default => nil

attribute :db_name, :kind_of => String, :default => nil
attribute :db_user, :kind_of => String, :default => nil
attribute :db_pwd, :kind_of => String, :default => nil
attribute :db_host, :kind_of => String, :default => nil
attribute :elb, :kind_of => String, :default => nil
attribute :salt, :kind_of => String, :default => ''
attribute :cache_prefix, :kind_of => String, :default => nil
attribute :sites_caches, :kind_of => Array, :default => []
attribute :site_dns, :kind_of => String, :default => 'www.example.net'
attribute :memcache_host, :kind_of => String, :default => nil
attribute :redis_host, :kind_of => String, :default => nil
attribute :cache_type, :kind_of => String, :default => 'none'
attribute :admin_url, :kind_of => String, :default => 'admin'
