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
      raise NotUserVagrant, "deploy command requires user vagrant" if ENV['USER'] != "vagrant"
      # Hack                                                                                                                                                                                                                                      
      ports = {"woot_learning_model"=>"3000", "woot_storage"=>"3001", "woot_roster"=>"3002", "woot_cms"=>"3003", "woot_db"=>"3004"}
      `sudo cp #{project.directory}/config/location.conf /etc/nginx/conf.d/location/#{project.name}.conf`
      `sudo cp #{project.directory}/config/upstream.conf /etc/nginx/conf.d/upstream/#{project.name}.conf`
      template = File.join(Kudu.template_dir, "init.d.erb")
      outfile = File.join(project.directory, "build", "#{project.name}.init.d")
      ErubisInflater.inflate_file_write(template, {project_name:project.name, project_version:project.version, port:ports[project.name]}, outfile)
      `sudo cp #{outfile} /etc/init.d/#{project.name}`
      `sudo chmod 755 /etc/init.d/#{project.name}`
      Kudu.ui.info("#{project.name} deployed")
    end

  end

end
