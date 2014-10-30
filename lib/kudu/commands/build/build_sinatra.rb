require 'rvm'
require 'etc'

require_relative '../../error'
require_relative '../../util'
require_relative '../../rvm_util'
require_relative '../../dependency_graph'
require_relative '../../ui'
require_relative '../../kudu_project'
require_relative 'gem_builder'

module Kudu

  class BuildSinatra
    
    def initialize(options, project)

      builder = GemBuilder.new(options, project)
      # production builds update version first
      builder.update_version if options[:production] 

      # init.d
      template = File.join(Kudu.template_dir, "init.d.erb")
      outfile = File.join(project.directory, "build", "#{project.name}-#{project.version}.init.d")
      # presence of config/sidekiq.yaml triggers init.d script with sidekiq support
      with_sidekiq = File.exists?(File.join(project.directory, 'config/sidekiq.yaml')) ? true : false
      ErubisInflater.inflate_file_write(template, {
                                          ruby:options[:ruby], 
                                          project_name:project.name, 
                                          project_version:project.version, 
                                          with_sidekiq:with_sidekiq
                                        }, outfile)

      # New sidekiq under god flow
      if with_sidekiq 

        template = File.join(Kudu.template_dir, "sidekiq.god.erb")
        outfile = File.join(project.directory, "config", "sidekiq.god")
        ErubisInflater.inflate_file_write(template, {project_name:project.name, project_version:project.version}, outfile)

        # init.d
        template = File.join(Kudu.template_dir, "god.init.d.erb")
        outfile = File.join(project.directory, "build", "#{project.name}-#{project.version}.god.init.d ")
        ErubisInflater.inflate_file_write(template, {
                                            ruby:options[:ruby], 
                                            project_name:project.name, 
                                            project_version:project.version,
                                            with_sidekiq:with_sidekiq
                                        }, outfile)
      end

      # nginx upstream
      template = File.join(Kudu.template_dir, "upstream.conf.erb")
      outfile = File.join(project.directory, "build", "#{project.name}-#{project.version}-upstream.conf")
      ErubisInflater.inflate_file_write(template, {project_name:project.name, project_version:project.version}, outfile)

      # nginx location 
      template = File.join(Kudu.template_dir, "location.conf.erb")
      outfile = File.join(project.directory, "build", "#{project.name}-#{project.version}-location.conf")
      ErubisInflater.inflate_file_write(template, {project_name:project.name, project_version:project.version}, outfile)

      # generate unicorn config before building sinatra project types
      template = File.join(Kudu.template_dir, "unicorn.erb")
      outfile = File.join(project.directory, "config", "unicorn.rb")
      num_workers = options[:'num-workers']
      ErubisInflater.inflate_file_write(template, {project_name:project.name, project_version:project.version, num_workers:num_workers}, outfile)

      # add version to config.ru 
      ru_file = File.join(project.directory, "config", "config.ru")
      unless File.exist?(ru_file) 
        ru_file = File.join(project.directory, "config.ru")
      end
      deploy_ru = File.join(project.directory, "config", "deploy.ru")
      IO.write(deploy_ru,IO.read(ru_file).gsub("require","gem \"#{project.name}\", \"#{project.version}\"; require"))

      # build the gem after generation of config files
      builder.build_gem unless options[:'only-third-party']
      builder.install_third_party unless options[:'skip-third-party']

    end

  end
end
