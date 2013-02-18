require 'rvm'
require 'etc'
require_relative '../../error'

module Kudu

  class CLI < Thor

    desc "clean", "Clean build environment"
    method_option :'clean-dependencies', :aliases => "-d", :required=>false, :desc => "Also clean dependencies"
    method_option :all, :aliases => "-a", :type => :boolean, :required=>false, :desc => "Build everything"
    method_option :name, :aliases => "-n", :required=>false, :desc => "Gem name", :lazy_default => ""
    method_option :gemspec, :aliases => "-g", :required=>false, :desc => "Gemspec file name", :lazy_default => ""
    method_option :user, :aliases => "-u", :type=>:string, :required=>false, :default=>Etc.getlogin(),  :desc => "User gemset to list"
    
    def clean
      name = options[:name]
      gemspec = options[:gemspec]
      @user = options[:user]
      
      Kudu.validate_standard_options(options)
      
      if options[:all]
        Kudu.each { |name| clean_dependencies(name) } 
        exit(0)
      end
      
      name = name ? name : Kudu.get_name_from_gemspec(gemspec)        
      options[:'clean-dependencies'] ? clean_dependencies(name) : clean_one(name)
    end
    
    private
    
    def clean_dependencies(name)
      Kudu.with_logging(self, __method__) do
        DependencyGraph.in_house(name).each do |dep|
          clean_one(DependencyGraph.full_name(dep))
        end
      end
    end
    
    def clean_one name
      # Convert to full vertex descriptor if necessary
      vertex = DependencyGraph.vertex_from_name(name)
      gemspec = DependencyGraph.gemspec(vertex)
      current = Dir.pwd
      begin
        Kudu.ui.info "cleaning #{name}"
        basedir = File.dirname(gemspec)
        Dir.chdir(basedir)
        `rm -rf build`
        Kudu.ui.info `rvm @#{@user} do gem uninstall -q -x #{name}` 
      ensure
        Dir.chdir(current)
      end
    end

  end
end
