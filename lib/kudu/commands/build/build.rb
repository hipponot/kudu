require 'rvm'
require 'etc'
require 'rubygems/builder'
require 'rubygems/installer'

require 'ruby-prof' unless RUBY_PLATFORM=='java'

require_relative '../../error'
require_relative '../../util'
require_relative '../../ui'
require_relative '../../kudu_project'

module Kudu

  class CLI < Thor

    desc "build", "Build gem"

    method_option :name, :aliases => "-n", :required=>false, :default=>File.basename(Dir.pwd), :desc => "Gem name", :lazy_default => ""
    method_option :all, :aliases => "-a", :type => :boolean, :required=>false, :desc => "Build everything"
    method_option :dependencies, :aliases => "-d", :required => false, :desc => "Rebuild dependencies before building"
    method_option :force, :aliases => "-f", :type => :boolean, :required => false, :default => false,  :desc => "Force rebuild"
    method_option :user, :aliases => "-u", :type => :string, :required => false, :default=>Etc.getlogin(),  :desc => "User gemset name"
    method_option :ffsf, :aliases => "-s", :type => :boolean, :required => false, :default=>false,  :desc => "Fast fast super fast"
    
    # No ruby-prof in jruby 
    @profile = RUBY_PLATFORM == 'java' ? false : options[:profile] 
    
    def build
      Kudu.with_logging(self, __method__) do
        if options[:all]
          Kudu.all.each { |project| build_one(project) } 
        elsif options[:'rebuild-dependencies']
          Kudu.dependencies(options[:name]).each { |project| build_one(project) } 
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
        Kudu.delegate_command('build', project.type, options)
      end

    end


  end
end
