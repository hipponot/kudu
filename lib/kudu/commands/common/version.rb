require_relative '../../version'

module Kudu

  class CLI < Thor

    desc "version", "print version of named gem"
    method_option :name, :aliases => "-n", :type => :string, :required=>true, :desc => "project name"
    def version
      project = KuduProject.project(options[:name])
      puts project.version
    end

  end

end
