require 'rvm'
require 'etc'
require 'fileutils'
require 'yaml'

require_relative '../../error'
require_relative '../../util'
require_relative '../../ui'
require_relative '../../kudu_project'
require_relative '../../dependency_graph'

module Kudu

  class CLI < Thor

    desc "package", "Package project"

    method_option :names, :aliases => "-n", :type => :array, :required=>true, :desc => "project names"
    method_option :package, :aliases => "-p", :type => :array, :required=>true, :desc => "package path"

    def package
      Kudu.with_logging(self, __method__) do
        projects = []
        third_party = []
        in_house = []
        options[:names].each do |name|
          projects << project = KuduProject.project(name)
          third_party.concat project.dependencies('third-party')
          in_house.concat project.dependencies('in-house')
        end
        # remove duplicates
        [third_party, in_house].each{ |a| a.uniq!{ |p| [ p.name, p.version] }}
        build_package(projects, in_house, third_party)
      end
    end

    private

    def build_package(projects, in_house, third_party)
      package = File.join(options[:package])
      Dir.mkdir(package) unless File.directory?(package)
      [projects, in_house].flatten.each do |project|
        # so we can access project.directory
        project = KuduProject.project(project.name)
        target_dir = File.join(package, project.name)
        Dir.mkdir(target_dir) unless File.directory?(target_dir)
        build_options = { name:project.name, force:true}
        cmd = "kudu clean -n #{project.name}"
        puts `#{cmd}`
        cmd = "kudu build -n #{project.name}"
        puts `#{cmd}`
        FileUtils.cp_r(File.join(project.directory, 'build/.'), target_dir)
      end
      # installer
      outfile = File.join(package, "install.rb")
      template = File.join(Kudu.template_dir, "install.rb.erb")
      ErubisInflater.inflate_file_write(template, {}, outfile)
      `chmod +x #{outfile}`
      # third party
      File.open(File.join(package,"third_party.yaml"), 'w') {
        |f| f.write(third_party.map {|d| {name:d.name, version:d.version} }.to_yaml) 
      }
      # tarball
      `tar cvf #{package}.tar #{package}`
      `gzip -f #{package}.tar`
    end


  end
end
