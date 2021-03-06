require 'thor'

module Kudu

  class CLI < Thor

    desc "create-project", "Create a skelton kudu project"
    method_option :name, :type=>:string, :aliases => "-n", :required=>true, :desc => "Project name"
    method_option :module_name, :type=>:string, :aliases => "-m", :required=>false, :desc => "Module name"
    method_option :type, :type=>:string, :aliases => "-t", :required=>true, :default=>'sinatra', :desc => "Project type"
    method_option :native_extension, :type=>:boolean, :aliases => "-e", :required=>false, :default=>false, :desc => "C-Native extension (ruby types only)"
    method_option :use_namespace, :type=>:boolean, :aliases => "-s", :required=>false, :default=>false, :desc => "First token in snake cased name used as enclosing namespace"
    method_option :force, :type=>:boolean, :aliases => "-f", :required=>false, :desc => "Force overwrite if project of this name exists"
    method_option :patch, :type=>:boolean, :aliases => "-pa", :required=>false, :desc => "Only overwrite non-existent files"
    method_option :backup, :type=>:boolean, :aliases => "-b", :required=>false, :default=>false, :desc => "Make backups of overwritten files"
    method_option :dependencies, :type=>:array, :aliases => "-d", :required=>false, :default=>[], :desc => "Dependencies"
    method_option :publications, :type=>:array, :aliases => "-p", :required=>false, :default=>[], :desc => "Publications"
    method_option :repo, :aliases => "-r", :type => :string, :required => false, :default=>"default",  :desc => "Repository name (published artifacts)"

    def create_project
      #delegate to type specific command
      unless Kudu.command_defined_for_type?(__method__.to_s, options[:type])
        Kudu.ui.error("#{__method__} command is not defined for project type " + options[:type])
      else
        Kudu.delegate_command(__method__.to_s, options[:type], options)
      end
    end

  end
end
