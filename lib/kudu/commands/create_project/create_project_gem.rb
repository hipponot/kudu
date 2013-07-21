require_relative 'create_project_base'

module Kudu

  class CreateProjectGem < CreateProjectBase

    def initialize(options)
      super
      # Settings specific to Sinatra project type, the rest are set in the base class
      settings[:project_type] = 'gem'
      settings[:native_extension] = options[:native_extension]
      settings[:publications] << {:name=>options[:name], :version=>'0.0.1', :type=>'gem', :group=>'in-house'}
      project_name = settings[:project_name]
      # create project structure
      with_logging("Creating project skeleton named #{project_name}") { create_project_skeleton }
      templates = { 
        "Rakefile.erb" => "Rakefile",
        "gemspec.erb" => "#{project_name}.gemspec", 
        "version.erb" => File.join('lib', project_name, 'version.rb'), 
        "module.erb" => File.join('lib', "#{project_name}.rb"), 
        "kudu.erb" => "kudu.yaml"
      }
      templates.each { |k,v| with_logging("wrote #{k}") { elaborate(k,v)} }
    end

  end
end
