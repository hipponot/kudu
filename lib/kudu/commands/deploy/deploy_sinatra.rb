require 'rvm'
require 'etc'

require_relative '../../error'
require_relative '../../util'
require_relative '../../rvm_util'
require_relative '../../dependency_graph'
require_relative '../../ui'
require_relative '../../kudu_project'

module Kudu

  class DeploySinatra

    def initialize(options, project)
      # out until we know how to use it
#      `sudo cp #{project.directory}/config/upstream.conf #{options[:'nginx-conf']}/conf.d/upstream/#{project.name}.conf`
      template = File.join(Kudu.template_dir, "init.d.erb")
      outfile = File.join(project.directory, "build", "#{project.name}.init.d")
      ErubisInflater.inflate_file_write(template, {env:options[:env], ruby:options[:ruby], user:options[:user], project_name:project.name, project_version:project.version, port:options[:port]}, outfile)
      # init.d
      initd = "/etc/init.d/#{project.name}-#{options[:port]}"
      `sudo cp #{outfile} #{initd}`
      `sudo chmod 755 #{initd}`
      # nginx location 
      template = File.join(Kudu.template_dir, "location.conf.erb")
      outfile = File.join(project.directory, "build", "location.conf")
      ErubisInflater.inflate_file_write(template, {project_name:project.name, port:options[:port]}, outfile)
      location = "#{options[:'nginx-conf']}/etc/nginx/conf.d/location/#{project.name}-#{options[:port]}.conf"
      `sudo cp #{outfile} #{location}`
    end

  end

end
