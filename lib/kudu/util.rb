require 'digest'
require_relative 'error'

class String
  def camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end
end

module Kudu

  class << self

    def command_defined_for_type?(command, type)
      classname = (command + '_' + type).camel_case
      eval("defined?(#{classname}) && #{classname}.is_a?(Class)")
    end

    def delegate_command(command, type, options, *args)
      classname = (command + '_' + type).camel_case
      if args.empty?
        eval("#{classname}.new(options)")
      else
        # unbox varags before instantiating the delegate
        args_str = ""
        args.each_with_index {|a,i| args_str += "args[#{i}]"; args += "," unless args.length-1}
        eval("#{classname}.new(options, #{args_str})")
      end
    end
    
    def each
      begin
        Dir.glob(File.join(Kudu.gitroot,'**/*.gemspec')).each do |gemspec|
          next unless File.exist?(File.join(File.dirname(gemspec),'kudu.yaml'))
          yield Kudu.get_name_from_gemspec(gemspec)
        end
      rescue Exception => e
        Kudu.ui.error "Error: Kudu.all failed on #{e}"
      end
    end
    
    def with_logging(obj, method, message=nil)
      Kudu.with_friendly_errors {
        begin
          Kudu.ui.info "#{obj.to_s}::#{method}: #{message}" if verbose
          yield
        rescue
          Kudu.ui.error "Error: #{obj.to_s}::#{method} failed"
          raise
        end
      }
    end

    def validate_standard_options options
      all = options[:all] 
      name = options[:name] 
      gemspec = options[:gemspec]
      if name && name.empty?
        raise InvalidOption, "Option -n cannot be empty - please specify valid gem name"
      end
      if gemspec && gemspec.empty?
        raise InvalidOption, "Option -g cannot be empty - please specify valid gemspec"
      end
      if all && (name || gemspec)
        raise InvalidOption, "The -a (all) option is inconsistent with -n or -g"
      end
      if name && gemspec
        raise InvalidOption, "Please specify target gem with either the options -g or the -n option"
      end
    end

    def verbose
      @verbose ||= false
    end
    
    def verbose= value
      @verbose = value
    end

    def gitroot
      `git rev-parse --show-toplevel`.chomp
    end
    def kudu_root
      File.expand_path(File.join(__FILE__, '../../../'))
    end
    
    def template_dir
      File.join(kudu_root, 'templates')
    end

    def get_name_from_gemspec(gemspec)
      unless gemspec
        gemspec = Dir.glob('*.gemspec').first
        raise Kudu::GemfileNotFound, 'Failed to find gemspec file, use the -n or -g option or run from a directory containting a gemspec' if gemspec.nil?
      end
      begin
        Gem::Specification::load(gemspec).name
      rescue
        raise Kudu::InvalidGemfile, "Failed to parse #{gemspec}" 
      end
    end

    def parse_kudu_file kudu_file
      return nil unless File.exist?(kudu_file)
      begin
        kudu = YAML::load(IO.read(kudu_file))
        if !kudu[:publication].is_a?(Hash)
            #          raise Kudu::InvalidKudufile, "Kudufile #{kudu_file} missing publication: Hash"
          elsif !kudu[:dependencies].is_a?(Array)
            #          raise Kudu::InvalidKudufile, "Kudufile #{kudu_file} missing dependencies: Array"
          else
            return kudu
          end
        rescue
          raise Kudu::InvalidKudufile, "Failed to parse #{kudu_file} as YAML" 
        end
      end

      def git_ls_files dir
        files = []
        files += `git ls-files --others --exclude-from=#{File.join(Kudu.gitroot, '.gitignore')} #{dir}`.split(/\r?\n/)
        files += `git ls-files #{dir}`.split(/\r?\n/)
      end

      def source_hash rootdir
        files = git_ls_files rootdir
        # Deal with 'git ls-files' not managing symlinks
        links = []
        files.each do |f|
          if File.symlink? f
            #readlink is relative to f's dirname
            ff = File.expand_path(File.join(File.dirname(f), `readlink #{f}`))
            links += git_ls_files ff
            files.delete(f)
          end
        end
        files += links
        # Don't hash sha1 file or built gem
        files = files.select { |f| not /\w*.gem$|sha1$/ =~ f }
        sha1 = Digest::SHA1.new
        files.each do |file|
          sha1.update(`git hash-object #{file}`)
        end
        sha1.to_s
      end

    end
  end

