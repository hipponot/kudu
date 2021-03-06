
require 'rvm'
require 'etc'

require_relative '../../error'
require_relative '../../util'
require_relative '../../ui'
require_relative '../../kudu_project'
require_relative '../../dependency_graph'

module Kudu

  class CLI < Thor

    desc "deploy", "Deploy project"

    method_option :name, :aliases => "-n", :type => :string, :required=>true, :desc => "project name"
    method_option :'nginx-conf', :aliases => "-g", :type => :string, :default=>"/etc/nginx", :required => false, :desc => "nginx conf directory"
    method_option :ruby, :aliases => "-v", :type => :string, :required => true, :default=>`rvm current`.chomp,  :desc => "ruby-version"
    method_option :repo, :aliases => "-r", :type => :string, :required => false, :default=>"default",  :desc => "repository name"

    def deploy
      Kudu.with_logging(self, __method__) do
        deploy_one(KuduProject.project(options[:name]))
      end
    end

    private

    def deploy_one project
      unless Kudu.command_defined_for_type?('deploy', project.type)
        Kudu.ui.error("deploy command is not defined for project type " + project.type)
      else
        Kudu.delegate_command('deploy', project.type, options, project)
      end
    end

  end
end
