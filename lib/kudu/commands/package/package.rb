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

    method_option :name, :aliases => "-n", :type => :string, :required=>true, :desc => "project name"
    method_option :'static-dir', :aliases => "-s", :type => :string, :required=>true, :desc => "package directory"
    method_option :'package-dir', :aliases => "-d", :type => :string, :required=>true, :desc => "package directory"
    method_option :force, :aliases => "-f", :type => :boolean, :required=>false, :default=>false, :desc => "overwrite existing package"
    method_option :ruby, :aliases => "-v", :type => :string, :required => true, :default=>`rvm current`.chomp,  :desc => "ruby-version"
    method_option :'num-workers', :aliases => "-w", :required=>false, :type=>:numeric, :default=>4, :desc=>"Number of unicorn workers to write to unicorn.rb"
    method_option :production, :required=>false, :type=>:boolean, :default=>true, :desc=>"Production package (RACK_ENV)"
    method_option :'bump-version', :required=>false, :type=>:boolean, :default=>true, :desc=>"Production build increments version"
    def package
      Kudu.with_logging(self, __method__) do
        project = KuduProject.project(options[:name])
        unless Kudu.command_defined_for_type?('package', project.type)
          Kudu.ui.error("package command is not defined for project type " + project.type)
        else
          Kudu.delegate_command('package', project.type, options, project, self)
        end
      end
    end

  end
end
