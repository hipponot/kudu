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
      outfile = File.join(project.directory, "build", "#{project.name}-#{project.version}.init.d")
      initd = "/etc/init.d/#{project.name}-#{project.version}"
      run_and_echo("sudo cp #{outfile} #{initd}")
      run_and_echo("sudo chmod 755 #{initd}")

      # nginx upstream
      outfile = File.join(project.directory, "build", "#{project.name}-#{project.version}-upstream.conf")
      upstream = "#{options[:'nginx-conf']}/conf.d/upstream/#{project.name}-#{project.version}.conf"
      run_and_echo("sudo cp #{outfile} #{upstream}")

      # nginx location 
      outfile = File.join(project.directory, "build", "#{project.name}-#{project.version}-location.conf")
      location = "#{options[:'nginx-conf']}/conf.d/location/#{project.name}-#{project.version}.conf"
      run_and_echo("sudo cp #{outfile} #{location}")
      puts "deployed #{project.name}-#{project.version}"
    end
    
    def run_and_echo cmd
      puts cmd
      system(cmd)
    end

  end

end
