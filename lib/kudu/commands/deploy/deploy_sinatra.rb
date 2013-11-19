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
      outfile = File.join(project.directory, "build", "#{project.name}.init.d")
      initd = "/etc/init.d/#{project.name}-#{project.version}"
      `sudo cp #{outfile} #{initd}`
      `sudo chmod 755 #{initd}`

      # nginx upstream
      outfile = File.join(project.directory, "build", "upstream.conf")
      upstream = "#{options[:'nginx-conf']}/conf.d/upstream/#{project.name}-#{project.version}.conf"
      `sudo cp #{outfile} #{upstream}`

      # nginx location 
      outfile = File.join(project.directory, "build", "location.conf")
      location = "#{options[:'nginx-conf']}/conf.d/location/#{project.name}-#{project.version}.conf"
      `sudo cp #{outfile} #{location}`
      puts "deployed #{project.name}-#{project.version}"
    end

  end

end
