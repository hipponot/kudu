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

      desc "clean", "Clean project"

      method_option :name, :aliases => "-n", :required=>false, :default=>nil, :desc => "Project name", :lazy_default => ""
      method_option :all, :aliases => "-a", :type => :boolean, :required=>false, :desc => "clean everything"
      method_option :dependencies, :aliases => "-d", :required => false, :desc => "Rebuild dependencies before building"
      method_option :repo, :aliases => "-r", :type => :string, :required => false, :default=>"default",  :desc => "Repository name (published artifacts)"
      method_option :'more-clean', :aliases => "-m", :type => :boolean, :required => false, :default=>false,  :desc => "more clean"      
      method_option :'nuke', :aliases => "-N", :type => :boolean, :required => false, :default=>false,  :desc => "nuke"      

      def clean
        Kudu.with_logging(self, __method__) do
          if options[:all]
            DependencyGraph.new.build_order { |project| clean_one(project) } 
          elsif options[:dependencies]
            DependencyGraph.new.build_order(options[:name]).each { |project| clean_one(project) } 
          else
            clean_one(KuduProject.project(options[:name]))
          end
        end
      end

      private

      def clean_one project
        unless Kudu.command_defined_for_type?('clean', project.type)
          Kudu.ui.error("clean command is not defined for project type " + project.type)
        else
          Kudu.delegate_command('clean', project.type, options, project)
        end
      end

    end

end
