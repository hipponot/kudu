require_relative "create_project_base"


module Kudu

  class CreateProjectSinatra < CreateProjectBase

    def initialize(options)
      super
      # Settings specific to Sinatra project type, the rest are set in the base class
      settings[:project_type] = "sinatra"
      settings[:publications] << {:name=>options[:name], :version=>"0.0.1", :type=>"gem", :group=>"in-house"}
      settings[:dependencies] << {:name=>"sinatra", :group=>"third-party", :type=>"gem"} << {:name=>"json", :group=>"third-party", :type=>"gem"} << {:name=>"shotgun", :group=>"developer", :type=>"gem"} 

      with_logging("Creating project skeleton named #{project_name}") { create_project_skeleton }
      with_logging("wrote Rakefile") { elaborate("Rakefile.erb", "Rakefile") }
      with_logging("wrote gemfile") { elaborate("Gemfile.erb", "Gemfile") }
      with_logging("wrote gemspec") { elaborate("gemspec.erb", "#{project_name}.gemspec") }
      with_logging("wrote version") { elaborate("version.erb", File.join("lib", project_name, "version.rb")) }
      with_logging("wrote module") { elaborate("sinatra.erb", File.join("lib", "#{project_name}.rb")) }
      with_logging("wrote config.ru") { elaborate("config.ru.erb", "config.ru") }
      with_logging("wrote kudu") { elaborate("kudu.erb", "kudu.yaml") }
    end

  end
end
