require 'rvm'
require 'etc'
require 'ruby-prof' unless RUBY_PLATFORM=='java'

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
      # generate unicorn config before building sinatra project types
      template = File.join(Kudu.template_dir, "unicorn.erb")
      outfile = File.join(project.directory, "config", "unicorn.rb")
      ErubisInflater.inflate_file_write(template, {project_name:project.name, project_version:project.version}, outfile)

      # add version to config.ru 
      ru_file = File.join(project.directory, "config", "config.ru")
      deploy_ru = File.join(project.directory, "config", "deploy.ru")
      IO.write(deploy_ru,IO.read(ru_file).gsub("require","gem \"#{project.name}\", \"#{project.version}\"; require"))

      # build the gem
      GemBuilder.new(options, project)
    end

  end
end
