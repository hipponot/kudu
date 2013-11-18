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

      build_dir = File.join(project.directory,'build')
      Dir.mkdir(build_dir) unless File.directory?(build_dir)

      # init.d
      template = File.join(Kudu.template_dir, "init.d.erb")
      outfile = File.join(project.directory, "build", "#{project.name}.init.d")
      ErubisInflater.inflate_file_write(template, {env:options[:env], ruby:options[:ruby], user:options[:user], project_name:project.name, project_version:project.version}, outfile)
      initd = "/etc/init.d/#{project.name}-#{project.version}"
      `sudo cp #{outfile} #{initd}`
      `sudo chmod 755 #{initd}`

      # nginx upstream
      template = File.join(Kudu.template_dir, "upstream.conf.erb")
      outfile = File.join(project.directory, "build", "upstream.conf")
      ErubisInflater.inflate_file_write(template, {project_name:project.name, project_version:project.version}, outfile)
      upstream = "#{options[:'nginx-conf']}/conf.d/upstream/#{project.name}-#{project.version}.conf"
      `sudo cp #{outfile} #{upstream}`

      # nginx location 
      template = File.join(Kudu.template_dir, "location.conf.erb")
      outfile = File.join(project.directory, "build", "location.conf")
      ErubisInflater.inflate_file_write(template, {project_name:project.name, project_version:project.version}, outfile)
      location = "#{options[:'nginx-conf']}/conf.d/location/#{project.name}-#{project.version}.conf"
      `sudo cp #{outfile} #{location}`
      puts "deployed #{project.name}-#{project.version}"
    end

  end

end
