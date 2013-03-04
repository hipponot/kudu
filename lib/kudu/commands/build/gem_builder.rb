require 'rvm'
require 'etc'
require 'rubygems/builder'
require 'rubygems/installer'

require 'ruby-prof' unless RUBY_PLATFORM=='java'

require_relative '../../error'
require_relative '../../util'
require_relative '../../rvm_util'
require_relative '../../dependency_graph'
require_relative '../../ui'
require_relative '../../kudu_project'

module Kudu

  module GemBuilder

    def initialize(options, project)    
      
      Kudu.with_logging(self, __method__) do

        @force = options[:force] || options[:odi]
        @repo = options[:repo]
        @odi = options[:odi]

        build_gem(project)

      end
    end

    def build_gem(project)
      Kudu.with_logging(self, __method__) do

        begin
          raise GemsBuilderFailed, "GemBuilder needs single @publication in publications array" unless project.publications.length == 1
          @publication = project.publications.first
          unless has_changed(project)
            Kudu.ui.info "Already installed and no local changes, skipping #{@publication.name}:"
            return
          end
          gemspec = File.join(project.directory, "#{project.name}.gemspec")
          raise GemBuilderFailed, "can't stat #{gemspec}" unless File.exist?(gemspec)
          current = Dir.pwd
          begin
            Dir.chdir(project.directory)
            build_dir = File.join(project.directory,'build')
            Dir.mkdir(build_dir) unless File.directory?(build_dir)
            `gem build #{gemspec}`
            gem_name = "#{@publication.name}-#{@publication.version}.gem"
            FileUtils.mv File.join(project.directory, gem_name), File.join(build_dir, gem_name)
            Dir.chdir(build_dir)
            `gem install -l -f --no-ri --no-rdoc #{gem_name}`
            Kudu.ui.info "Installed #{gem_name} in group #{@publication.group}"
            odi(project) if @odi
          ensure
            Dir.chdir(current)
          end
        rescue Exception => e
          raise GemBuilderFailed, "Gem build failed: #{e.message}"
        end
      end
    end

    def has_changed(project)
      Kudu.with_logging(self, __method__) do
        return @force if @force
        begin
          local_hash = Kudu.source_hash(project.directory)
          install_hash = installed_gem_source_hash(project)
          if local_hash != install_hash
            IO.write(File.join(project.directory, 'lib', @publication.name, 'sha1'), local_hash)
            return true
          end
          false
        rescue Exception => e
          raise GemBuilderFailed, "Gem build failed: #{e.message}"
        end
      end
    end

    def installed_gem_source_hash(project)
      Kudu.with_logging(self, __method__) do
        files = `gem contents #{@publication.name} --version #{@publication.version}`.split($/)
        files.each do |file|
          if file =~/sha1/
            sha1 = IO.read(file)
            return sha1
          end
        end
        return nil
      end                               
    end
    
    def odi(project)
      Kudu.with_logging(self, __method__) do
        targets = `gem contents #{@publication.name} --version #{@publication.version}`.split($/) 
        sources = targets.map { |f| project.directory + f.split(/#{full_name}-\d+\.\d+\.\d+/)[1] }
        for i in 0..sources.length-1
          next if sources[i] =~ /sha1/
          cmd = "ln -fF -s #{sources[i]} #{targets[i]}"
          system(cmd)
          print "ODI made the following links:"
          Kudu.ui.cyan(targets[i].gsub(ENV['HOME'],'~'),false);puts '->'; 
          Kudu.ui.blue(sources[i].gsub(ENV['HOME'],'~'))
        end
      end
    end

  end

end
