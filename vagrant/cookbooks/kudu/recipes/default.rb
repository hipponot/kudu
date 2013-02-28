package "curl" do
  package_name "curl"
  action :install
end

package "make" do
  package_name "make"
  action :install
end

package "g++" do
  package_name "g++"
  action :install
end


package "git" do
  package_name "git"
  action :install
end

execute "bootstrap kudu" do
  cwd '/home/vagrant/kudu/bin'
  action :nothing
  command "su vagrant -l -c '/home/vagrant/kudu/bin/kudu bootstrap'"
end

execute "install JRuby" do
  action :nothing
  command "su vagrant -l -c 'rvm install jruby'"
  notifies :run, resources(:execute => "bootstrap kudu")
end

execute "install RVM" do
  cwd '/home/vagrant'
  action :run
  command "su vagrant -l -c 'curl -L https://get.rvm.io | bash -s stable --ruby'"
  notifies :run, resources(:execute => "install JRuby")
end




