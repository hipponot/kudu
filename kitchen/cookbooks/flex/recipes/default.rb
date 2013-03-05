TMP_FLEX_SDK = "/tmp/flex_sdk_4.6.zip" 
TMP_AIR_SDK = "/tmp/AIRSDK_Compiler.tbz2"
FLEX_HOME = "/opt/flex/flex_sdk_4.6" 
AIR_HOME = "/opt/flex/air_sdk_3.6" 

ruby_block "install" do
 action :nothing
 block do
   `tar xzf #{TMP_FLEX_SDK} -C #{FLEX_HOME}`
   `tar xzf #{TMP_AIR_SDK} -C #{AIR_HOME}`
 end
end

remote_file TMP_FLEX_SDK do
  source "http://erdos.local/pkg/flex_sdk_4.6.zip"
  owner "root"
  group "admin"
  mode 0644
  action :create_if_missing
end

remote_file TMP_AIR_SDK do
  source "http://erdos.local/pkg/AIRSDK_Compiler.tbz2"
  mode 0644
  owner "root"
  group "admin"
  action :create_if_missing
end

directory AIR_HOME do
  owner "root"
  group "admin"
  recursive true
  mode 0755
  action :create
end

directory FLEX_HOME do
  owner "root"
  group "admin"
  recursive true
  mode 0755
  action :create
  notifies :create, "ruby_block[install]"
end






  
