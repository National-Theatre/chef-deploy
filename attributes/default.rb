#
# Cookbook Name:: nt-deploy
# Attributes:: default
#
# Copyright 2015, National Theatre
#
# All rights reserved - Do Not Redistribute
#

default['nt-deploy']['sites'] = []
default['nt-deploy']['ssh_dir'] = "~/.ssh"
default['nt-deploy']['grid_bag'] = "deploy_keys"
default['nt-deploy']['github'] = ''
default['nt-deploy']['mysql']['initial_user'] = 'ntdbo'
default['nt-deploy']['mysql']['initial_root_password'] = 'changeme'
default['nt-deploy']['code_version'] = 'v2.0.7'
default['nt-deploy']['bookshop_version'] = 'v1.0.0'

default['nt-deploy']['default']['db_host']     = 'localhost'
default['nt-deploy']['default']['elb']         = '"127.0.0.1"'
default['nt-deploy']['default']['memcache']    = '"127.0.0.1"'
default['nt-deploy']['default']['redis']       = '"127.0.0.1"'
default['nt-deploy']['default']['aws_key']     = 'changeme'
default['nt-deploy']['default']['aws_secret']  = 'changeme'
default['nt-deploy']['swap_mem_size']          = '512'
