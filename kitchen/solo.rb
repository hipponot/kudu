file_cache_path "/tmp/chef-solo"
file_backup_path "/tmp/chef-solo/backup"
cookbook_path [File.expand_path(File.join(File.dirname(__FILE__),'cookbooks'))]
# Very annoying but necessary override for non-privlidged user
Chef::Config[:cache_options]={:path=>"/tmp/chef-solo/checksums"}

