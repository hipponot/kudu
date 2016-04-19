require_relative 'create_project_base'

module Kudu

  class CreateProjectThor < CreateProjectBase

    def initialize(options)
      super
      # Settings specific to Sinatra project type, the rest are set in the base class
      settings[:project_type] = 'gem'
      settings[:native_extension] = options[:native_extension]
      settings[:publications] << {:name=>options[:name], :version=>'1.0.1', :type=>'gem', :group=>'in-house'}
      project_name = settings[:project_name]
      # create project structure
      with_logging("Creating project skeleton named #{project_name}") { create_project_skeleton }
      templates = { 
        "do_test.erb" => "do_test.rb",
        "gemspec.erb" => "#{project_name}.gemspec", 
        "version.erb" => File.join('lib', project_name, 'version.rb'), 
        "thor/module.erb" => File.join('lib', "#{project_name}.rb"), 
        "thor/cli.erb" => File.join("lib/#{project_name}", "cli.rb"), 
        "thor/ui.erb" => File.join("lib/#{project_name}", "ui.rb"), 
        "thor/friendly_errors.erb" => File.join("lib/#{project_name}", "friendly_errors.rb"), 
        "thor/version.erb" => File.join("lib/#{project_name}/commands", "version.rb"), 
        "thor/bin.erb" => File.join("bin", "#{project_name}"), 
        "kudu.erb" => "kudu.yaml"
      }
      templates.each { |k,v| with_logging("wrote #{k}") { elaborate(k,v)} }
      # chmod stuff in bin
      Dir.glob(File.join(Dir.pwd, project_name, "bin/*")) { |f| system("chmod +x #{f}") }
    end

  end
end
