require 'rvm'
require 'etc'

require_relative '../../error'
require_relative '../../rvm_util'

module Kudu

  class CLI < Thor

    desc "service-start", "Start service appropriate for project type"
    method_option :project_name, :aliases => "-n", :required=>false, :desc => "Project name", :lazy_default => ""
    method_option :repo, :aliases => "-r", :type=>:string, :required=>false, :default=>Etc.getlogin(),  :desc => "Repository name to $USER"
    method_option :verbose, :aliases => "-v", :type=>:boolean, :required=>false, :default=>false,  :desc => "Verbose output"
    method_option :port, :aliases => "-p", :type=>:string, :required=>false, :default=>"9393",  :desc => "Port number"
    def service_start
      #delegate to type specific command
      p = KuduProject.project(options[:project_name])
      unless Kudu.command_defined_for_type?(__method__.to_s, p.type)
        Kudu.ui.error("#{__method__} command is not defined for project type " + p.type)
      else
        Kudu.delegate_command(__method__.to_s, p.type, options)
      end
    end
  end

end
