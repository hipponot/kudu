require_relative "create_project_base"


module Kudu

  class CreateProjectSinatra < CreateProjectBase

    def initialize(options)
      super
      # Settings specific to Sinatra project type, the rest are set in the base class
      settings[:project_type] = "sinatra"
      settings[:native_extension] = options[:native_extension]
      settings[:publications] << {:name=>options[:name], :version=>"0.0.1", :type=>"gem", :group=>"in-house"}
      settings[:dependencies] << {:name=>"sinatra", :group=>"third-party", :type=>"gem"} << {:name=>"json", :group=>"third-party", :type=>"gem"} << {:name=>"shotgun", :group=>"developer", :type=>"gem"} 

      with_logging("Creating project skeleton named #{project_name}") { create_project_skeleton }
      elaborate("Rakefile.erb", "Rakefile") 
      elaborate("Gemfile.erb", "Gemfile") 
      elaborate("gemspec.erb", "#{project_name}.gemspec") 
      elaborate("version.erb", File.join("lib", project_name, "version.rb")) 
      elaborate("sinatra.erb", File.join("lib", "#{project_name}.rb")) 
      # kudu build creates the versioned (deployable) config.ru
      elaborate("config.ru.erb", File.join("config","config.ru"))
      elaborate("extconf.erb", File.join("ext", project_name, "extconf.rb")) if options[:native_extension]
      elaborate("module.cpp.erb", File.join("ext", project_name, "#{project_name}.cpp")) if options[:native_extension]      
      elaborate("kudu.erb", "kudu.yaml") 
    end

  end
end
