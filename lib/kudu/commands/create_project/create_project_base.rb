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
        :namespace => (tokens.length > 1 and options[:use_namespace]) ? tokens.first : nil,
        :name => (tokens.length > 1 and options[:use_namespace]) ? tokens[1..tokens.length].join("_") : options[:name],
        :dependencies => options[:dependencies].map {|dep| eval(dep) },
        :publications => options[:publications].map {|pub| eval(pub) },
        :create_type => options[:type]
      }
      @settings[:name_cc] = options[:module_name] ? options[:module_name] : @settings[:name].camel_case
      @settings[:namespace_cc] = @settings[:namespace] ? @settings[:namespace].camel_case : nil
      # merge in repo specific settings or use defaults
      @settings.merge!(repository_settings)

      raise InvalidOption, " --patch and --force are not compatible" if options[:force] && options[:patch]
      @force = options[:force]
      @patch = options[:patch]
      @backup = options[:backup]
      @repo = options[:repo]
    end

    protected

    def create_project_skeleton
      target = File.join(Dir.pwd, project_name)
      if File.exist?(target) && !@force && !@patch
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
      FileUtils.mkdir_p(File.join(target, '.vscode'))
      FileUtils.mkdir_p(File.join(target, 'config'))
      FileUtils.mkdir_p(File.join(target, 'lib', project_name))
      FileUtils.mkdir_p(File.join(target, 'ext', "#{project_name}")) if settings[:native_extension]
      if settings[:create_type] == 'thor'
        FileUtils.mkdir_p(File.join(target, 'lib', project_name, 'commands'))
        FileUtils.mkdir_p(File.join(target, 'bin'))
      end

    end

    def elaborate(template_file, relative_output_file)
      outfile = File.join(Dir.pwd, project_name, relative_output_file)
      if @patch && File.exists?(outfile)
        Kudu.ui.info("File exists: #{outfile} - skipping")
        return
      end
      template = File.join(Kudu.template_dir, template_file)
      FileUtils.copy(outfile, outfile + ".bu") if @backup && File.exist?(outfile)
      begin
        ErubisInflater.inflate_file_write(template, settings, outfile)
        Kudu.ui.info("Wrote #{outfile}")
      rescue Exception => e
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
