require 'rvm'
require 'etc'
require 'rubygems/builder'
require 'rubygems/installer'

require 'ruby-prof' unless RUBY_PLATFORM=='java'

require_relative '../../error'
require_relative '../../util'
require_relative '../../ui'
require_relative '../../kudu_project'

module Kudu

  module FlexBuilder

    def initialize(options, project)    

      Kudu.with_logging(self, __method__) do

        @force = options[:force] || options[:odi]
        @repo = options[:repo]
        @odi = options[:odi]

        build_swf(project)
        install_third_party(project)

      end
    end

    def build_swf(project)
      Kudu.with_logging(self, __method__) do
        begin
          swfs = project.publications.select { |p| p.type == 'swf' }
          raise FlexBuilderFailed, "FlexBuilder can't build multiple swfs" unless swfs.length == 1
          @swf = swfs[0]
          begin
            @build_dir = File.join(project.directory,'build')
            Dir.chdir(project.directory)
            Dir.mkdir(@build_dir) unless File.directory?(@build_dir)
            Dir.chdir(@build_dir)
            unless has_changed(project)
              Kudu.ui.info "Already built and no local changes, skipping #{@publication.name}:"
              return
            end
            call_mxmlc
          ensure
            Dir.chdir(current)
          end
        rescue Exception => e
          raise FlexBuilderFailed, "Gem build failed: #{e.message}"
        end
      end
    end
    
    def call_mxmlc
      main_file = Dir.glob(project.directory + "**/main*.as")[0]
      raise FlexBuilderMainNotFound unless File.exist?(main_file)
      cmd = "mxmlc "
      cmd += " --source-path+=#{File.join(project.directory, 'src')}"
      cmd += " --library-path+=#{File.join(project.directory, 'lib')}" 
      cmd += " --main-file=#{main_file}"
    end
    
    def has_changed(project)
      Kudu.with_logging(self, __method__) do
        return @force if @force
        begin
          local_hash = Kudu.source_hash(project.directory)
          built_sha1 = File.join(@build_dir, 'sha1')
          built_hash = File.exist?(built_sha1) ? IO.read(built_sha1) : nil
          if local_hash != built_hash
            IO.write(File.join(@build_dir, 'sha1'), local_hash)
            return true
          end
          false
        rescue Exception => e
          raise FlexBuilderFailed, "Gem build failed: #{e.message}"
        end
      end
    end

    def odi(project)
      #FFSF goes here
    end

    def install_third_party project
      Kudu.with_logging(self, __method__) do
      end
    end

    def is_installed dep
      begin
      end
    end
  end

end
