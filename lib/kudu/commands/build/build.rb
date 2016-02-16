require 'rvm'
require 'etc'
require 'yaml'

require_relative '../../error'
require_relative '../../util'
require_relative '../../ui'
require_relative '../../kudu_project'
require_relative '../../dependency_graph'

module Kudu

  class CLI < Thor

    desc "build", "Build project"

    method_option :name, :aliases => "-n", :required=>false, :default=>nil, :desc => "Project name"
    method_option :all, :aliases => "-a", :type => :boolean, :required=>false, :desc => "Build everything"
    method_option :dependencies, :aliases => "-d", :required => false, :desc => "Rebuild dependencies before building"
    method_option :force, :aliases => "-f", :type => :boolean, :required => false, :default => false,  :desc => "Force rebuild"
    method_option :skip_third_party, :aliases => "-s", :type => :boolean, :required => false, :default => false,  :desc => "Skip third party gem install"
    method_option :only_third_party, :aliases => "-s", :type => :boolean, :required => false, :default => false,  :desc => "Only build and install third party deps"
    method_option :repo, :aliases => "-r", :type => :string, :required => false, :default=>"default",  :desc => "Repository name (published artifacts)"
    method_option :odi, :aliases => "-o", :type => :boolean, :required => false, :default=>false,  :desc => "Optimized for developer iterations"
    method_option :version, :type => :string, :required => true, :default=>'1', :desc => "Revision"
    method_option :dry_run, :aliases => "-y", :type => :boolean, :required => false, :default=>false,  :desc => "Dry run"
    method_option :ruby, :aliases => "-v", :type => :string, :required => true, :default=>`rvm current`.chomp,  :desc => "ruby-version"
    method_option :install, :aliases => "-i", :type => :boolean, :required => false, :default=>true,  :desc => "install built gem"    

    def build
      Kudu.with_logging(self, __method__) do
        if options[:all]
          DependencyGraph.new.build_order.each { |project|
            Kudu.ui.info("-- Building #{project.name}")
            build_one(project)
          }
        elsif options[:dependencies]
          DependencyGraph.new.build_order(options[:name]).each do |project|
            Kudu.ui.info("-- Building #{project.name}")
            build_one(project) 
          end
        else
          build_one(KuduProject.project(options[:name]))
        end
      end
    end

    private

    def build_one project
      project.pre_build.each do |pre|
        pre = File.expand_path(File.join(project.directory, pre))
        raise Error.new("Can't stat pre build script #{pre}") unless File.exist?(pre)
        Kudu.ui.info("executing pre build step #{pre}")
        status = system(pre)
        raise Error.new("Bad return status from pre build script #{pre}") unless status
      end

      # Version is eithers a revision (e.g. single number) or ruby
      # rational version string x.x.x.  If it is the latter it is set
      # literally the former is constructed using the MAGOR_MINOR
      # revision of the project and the specified revision
      project.set_version options[:version]

      # create build directory
      build_dir = File.join(project.directory,'build')
      Dir.mkdir(build_dir) unless File.directory?(build_dir)
      # force the version bump if requested
      unless Kudu.command_defined_for_type?('build', project.type)
        Kudu.ui.error("build command is not defined for project type " + project.type)
      else
        Kudu.delegate_command('build', project.type, options, project)
      end
    end

  end
end
