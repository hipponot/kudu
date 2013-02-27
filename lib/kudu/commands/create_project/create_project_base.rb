require_relative '../../util'
require_relative '../../erubis_inflater'

module Kudu

  class CreateProjectBase

    def project_name
      @settings[:project_name]
    end
    
    def project_type
      @settings[:project_type]
    end

    def settings
      @settings
    end
    
    def initialize(options)

      tokens = options[:name].split("_")
      @settings = {
        :project_name => options[:name],
        :namespace => tokens.length > 1 ? tokens.first : nil,
        :name => tokens.length > 1 ? tokens[1..tokens.length].join("_") : options[:name],
        :dependencies => options[:dependencies].map {|dep| eval(dep) },
        :publications => options[:publications].map {|pub| eval(pub) }
      }
      @settings[:name_cc] = @settings[:name].camel_case
      @settings[:namespace_cc] = @settings[:namespace] ? @settings[:namespace].camel_case : nil
      # merge in repo specific settings or use defaults
      @settings.merge!(repository_settings)

      @force = options[:force]
      @backup = options[:backup]
      @repo = options[:repo]
    end

    protected

    def create_project_skeleton
      target = File.join(Dir.pwd, project_name)
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
      FileUtils.mkdir_p(File.join(target, 'lib', project_name))
    end

    def elaborate(template_file, relative_output_file)
      template = File.join(Kudu.template_dir, template_file) 
      outfile = File.join(Dir.pwd, project_name, relative_output_file)
      FileUtils.copy(outfile, outfile + ".bu") if @backup && File.exist?(outfile)
      begin
        ErubisInflater.inflate_file_write(template, settings, outfile)
      rescue
        raise TemplateElaborationFailed, "Failed to elaborate template file #{template}"
      end
    end

    def repository_settings
      config = Kudu.gitroot + '/config/default.yaml'
      if File.exist?(config)
        settings = YAML::load IO.read(config)
      else
        settings = {
          authors:['Sean Kelly'],
          emails: ['sean.kelly@wootlearning.com'],
          description: 'generic kudu module description',
          summary: 'generic kudu module summary',
          homepage: 'http://wootlearning.com'
        }
      end      
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
