require 'rvm'
require 'etc'
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
            current = Dir.pwd
            Dir.chdir(project.directory)
            Dir.mkdir(@build_dir) unless File.directory?(@build_dir)
            Dir.chdir(@build_dir)
            unless has_changed(project)
              Kudu.ui.info "Already built and no local changes, skipping #{@swf.name}:"
              return
            end
            call_flex(project)
          ensure
            Dir.chdir(current)
          end
        rescue Exception => e
          raise FlexBuilderFailed, "Gem build failed: #{e.message}"
        end
      end
    end

# #!/bin/sh


# #$AIR_SDK/bin/amxmlc -source-path src -output bin-debug/woot_math.swf src/woot/woot_math.as

# # Fill in content string


# # Run simulator (via wine, requires Linux setup:
# #  - install wine
# #  - http://askubuntu.com/questions/127848/wine-cant-find-gnome-keyring-pkcs11-so
# wine /opt/air_sdk_3.6/bin/adl.exe -screensize iPad -profile extendedMobileDevice bin-debug/woot_math.xml
    
  def call_flex(project)
      #SWF
      main_file = Dir.glob("#{project.directory}/**/#{@swf.name}.as")[0]
      raise FlexBuilderMainNotFound unless File.exist?(main_file)
      cmd = "mxmlc "
      cmd += " -output #{@build_dir}/#{@swf.name}.swf #{main_file}"
      cmd += " -source-path+=#{project.directory}/src"
      cmd += " -library-path+=#{project.directory}/lib"
      cmd += " -static-link-runtime-shared-libraries"
      puts cmd; system cmd
      #APP XML
      app_xml = Dir.glob("#{project.directory}/**/#{@swf.name}-app.xml")[0]
      raise FlexBuilderAppXMLNotFound unless File.exist?(app_xml)
      cmd = "cat #{app_xml} | sed -e 's,<content.*/content>,<content>#{@swf.name}.swf</content><renderMode>direct</renderMode>,' > #{@build_dir}/woot_math.xml"
      puts "wrote #{@build_dir}/woot_math.xml"; system cmd
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
