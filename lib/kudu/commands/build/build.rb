require 'rvm'
require 'etc'
require 'ruby-prof' unless RUBY_PLATFORM=='java'

require_relative '../../error'
require_relative '../../util'
require_relative '../../ui'
require_relative '../../kudu_project'
require_relative '../../dependency_graph'

module Kudu

  class CLI < Thor

    desc "build", "Build project"

    method_option :name, :aliases => "-n", :required=>false, :default=>nil, :desc => "Project name", :lazy_default => ""
    method_option :all, :aliases => "-a", :type => :boolean, :required=>false, :desc => "Build everything"
    method_option :dependencies, :aliases => "-d", :required => false, :desc => "Rebuild dependencies before building"
    method_option :force, :aliases => "-f", :type => :boolean, :required => false, :default => false,  :desc => "Force rebuild"
    method_option :repo, :aliases => "-r", :type => :string, :required => false, :default=>"default",  :desc => "Repository name (published artifacts)"
    method_option :odi, :aliases => "-o", :type => :boolean, :required => false, :default=>false,  :desc => "Optimized for developer iterations"
    method_option :dryrun, :aliases => "-", :type => :boolean, :required => false, :default=>false,  :desc => "Dry run"
    
    # No ruby-prof in jruby 
    @profile = RUBY_PLATFORM == 'java' ? false : options[:profile] 
    
    def build
      Kudu.with_logging(self, __method__) do
        if options[:all]
          DependencyGraph.new.build_order { |project| build_one(project) } 
        elsif options[:dependencies]
          DependencyGraph.new.build_order(options[:name]).each { |project| build_one(project) } 
        else
          build_one(KuduProject.project(options[:name]))
        end
      end
    end

    private

    def build_one project
      unless Kudu.command_defined_for_type?('build', project.type)
        Kudu.ui.error("build command is not defined for project type " + project.type)
      else
        Kudu.delegate_command('build', project.type, options, project)
      end
    end


  end
end
