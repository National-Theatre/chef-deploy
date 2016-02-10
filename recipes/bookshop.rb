#
# Cookbook Name:: nt-deploy
# Recipe:: bookshop
#
# Copyright 2015, National Theatre
#
# All rights reserved - Do Not Redistribute
#

mount 'bucket' do
    device "s3fs##{node['s3_bucket']}"
    fstype 'fuse'
    mount_point '/var/www/bookshop/magento/media'
    action [:enable, :mount]
    options "_netdev,allow_other,nonempty,iam_role=#{node['iam_role']}"
end
