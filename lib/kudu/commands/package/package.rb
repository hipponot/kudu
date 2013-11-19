require 'rvm'
require 'etc'
require 'fileutils'

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
    method_option :env, :aliases => "-e", :type => :string, :required => true, :desc => "environment"
    method_option :user, :aliases => "-u", :type => :string, :required => true, :desc => "user"

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
        build_options = { name:project.name }
        invoke :build, nil, build_options
        FileUtils.cp_r(File.join(project.directory, 'build/.'), target_dir)
      end
    end


  end
end
