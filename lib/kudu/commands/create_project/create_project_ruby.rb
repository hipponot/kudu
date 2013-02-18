require_relative '../../util'
require_relative '../../erubis_inflater'

module Kudu

  class CLI < Thor

    desc "create-gem", "Create a skelton kudu GEM project"
    method_option :name, :type=>:string, :aliases => "-n", :required=>true, :desc => "Gem name"
    method_option :namespace, :type=>:string, :aliases => "-s", :required=>false, :desc => "Gem namespace"
    method_option :force, :type=>:boolean, :aliases => "-f", :required=>false, :desc => "Force overwrite if project of this name exists"
    method_option :backup, :type=>:boolean, :aliases => "-b", :required=>false, :default=>false, :desc => "Make backups of overwritten files"
    method_option :dependencies, :type=>:array, :aliases => "-d", :required=>false, :default=>[], :desc => "Dependencies"
    method_option :sinatra, :type=>:boolean, :aliases => "-r", :required=>false, :default=>false, :lazy_default=>true, :desc => "Create a skeleton Sinatra application"

    def create_gem

      @name = options[:name]
      @name_cc = @name.camel_case
      @namespace = options[:namespace].nil? ? false : options[:namespace]
      @namespace_cc = @namespace ? @namespace.camel_case : false
      @force = options[:force]
      @backup = options[:backup]
      @fullname = @namespace ? @namespace + "_" + @name : @name
      @dependencies = []
      options[:dependencies].each do |dep| 
        @dependencies << eval(dep)
      end

      with_logging("Creating Gem skeleton named #{@fullname}") { create_project_skeleton }
      with_logging('wrote Rakefile') { elaborate('Rakefile.erb', 'Rakefile') }
      with_logging('wrote gemfile') { elaborate('Gemfile.erb', 'Gemfile') }
      with_logging('wrote gemspec') { elaborate('gemspec.erb', "#{@fullname}.gemspec") }
      with_logging('wrote version') { elaborate('version.erb', File.join('lib', @fullname, 'version.rb')) }
      module_template = !options[:sinatra] ? 'module.erb' : 'sinatra.erb'
      with_logging('wrote module') { elaborate(module_template, File.join('lib', "#{@fullname}.rb")) }
      if options[:sinatra] 
        @dependencies << {:name=>"sinatra", :group=>"third-party"} << {:name=>"json", :group=>"third-party"} << {:name=>"shotgun", :group=>"third-party"} 
        with_logging('wrote config.ru') { elaborate('config.ru.erb', 'config.ru') }
      end
      with_logging('wrote kudu') { elaborate('kudu.erb', 'kudu.yaml') }

    end

    private

    def initialize(options)
    end

    def create_project_skeleton
      target = File.join(Dir.pwd, @fullname)
      if File.exist?(target) && !@force
        Kudu.ui.info "#{target} exists, over-write ? (y/n)"
        overwrite = ''
        while overwrite != 'y' && overwrite != 'n'
          overwrite = STDIN.getc.downcase
        end
        if overwrite == 'n' 
          Kudu.ui.info 'exiting'
          return
        end
      end
      FileUtils.mkdir_p(File.join(target, 'lib', @fullname))
    end

    def elaborate(template_file, relative_output_file)
      template = File.join(Kudu.template_dir, template_file) 
      outfile = File.join(Dir.pwd, @fullname, relative_output_file)
      FileUtils.copy(outfile, outfile + ".bu") if @backup && File.exist?(outfile)
      ErubisInflater.inflate_file_write(template, settings, outfile)
    end

    def settings
      config = Kudu.gitroot + '/config/default.yaml'
      if File.exist?(config)
        settings = YAML::load IO.read(config)
      else
        settings = {
          authors:['Sean Kelly', 'Jeff Stroomer', 'Phil James-Roxby', 'Raul Rangel', 'James Bailey', 'Justin Bradley'],
          emails: ['cws@disney.com'],
          description: 'generic kudu module description',
          summary: 'generic kudu module summary',
          homepage: 'http://disney.com/create'
        }
      end      
      settings['name'] = @name
      settings['name_cc'] = @name_cc
      settings['fullname'] = @fullname
      settings['namespace'] = @namespace 
      settings['namespace_cc'] = @namespace_cc if @namespace
      settings['dependencies'] = @dependencies
      settings['publication'] = {name:@name, version:'0.0.1', group:'in-house'}
      settings['publication'][:namespace] = @namespace if @namespace
      settings
    end

    def with_logging(description)
      begin
        Kudu.ui.info "#{description}"
        yield
      rescue
        Kudu.ui.info "Error: #{description} failed"
        raise
      end
    end


  end
end
