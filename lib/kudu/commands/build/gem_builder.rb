require 'rvm'
require 'etc'

require_relative '../../error'
require_relative '../../util'
require_relative '../../rvm_util'
require_relative '../../dependency_graph'
require_relative '../../ui'
require_relative '../../kudu_project'

module Kudu

  class GemBuilder


    def initialize(options, project)    
      Kudu.with_logging(self, __method__) do
        @project = project
        @force = options[:force] || options[:odi]
        @repo = options[:repo]
        @odi = options[:odi]
        @production = options[:projection]
        @install = options[:install]
        raise GemsBuilderFailed, "GemBuilder needs single @publication in publications array" unless project.publications.length == 1
        @publication = project.publications.first
      end
    end
    attr_reader :project

    def build_gem
      Kudu.with_logging(self, __method__) do
        begin
          Kudu.rvm_use @repo
          unless has_changed(project)
            Kudu.ui.info "Already installed and no local changes, skipping #{@publication.name}:"
            return
          end
          gemspec = File.join(project.directory, "#{project.name}.gemspec")
          raise GemBuilderFailed, "can't stat #{gemspec}" unless File.exist?(gemspec)
          current = Dir.pwd
          begin
            Dir.chdir(project.directory)
            Kudu.ui.info `gem build #{gemspec}`
            build_dir = File.join(project.directory,'build')
            gem_name = "#{@publication.name}-#{@publication.version}.gem"
            FileUtils.mv File.join(project.directory, gem_name), File.join(build_dir, gem_name)
            if @install
              Dir.chdir(build_dir)
              Kudu.ui.info `gem install -l -f --no-ri --no-rdoc #{gem_name}`
              Kudu.ui.info "Installed #{gem_name} in group #{@publication.group}"
              odi(project) if @odi
            end
          ensure
            Dir.chdir(current)
          end
        rescue Exception => e
          raise GemBuilderFailed, "Gem build failed: #{e.message}"
        end
      end
    end

    def update_version
      Kudu.with_logging(self, __method__) do      
        Kudu.rvm_use @repo
        return unless is_installed? project
        local_hash = Kudu.source_hash(project.directory)
        install_hash = installed_gem_source_hash(project)
        if local_hash != install_hash
          project.bump_version
        end
      end
    end

    def has_changed(project)
      Kudu.with_logging(self, __method__) do
        begin
          local_hash = Kudu.source_hash(project.directory)
          install_hash = installed_gem_source_hash(project)
          if local_hash != install_hash
            IO.write(File.join(project.directory, 'lib', @publication.name, 'sha1'), local_hash)
            return true 
          end
          return false || @force
        rescue Exception => e
          raise GemBuilderFailed, "Unexpected exception in GemBuilder::has_changed: #{e.message}"
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
        sources = targets.map { |f| project.directory + f.split(/#{project.name}-\d+\.\d+\.\d+/)[1] }
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

    def install_third_party
      Kudu.with_logging(self, __method__) do
        return unless @install
        Kudu.rvm_use 'global'
        # Convert to full vertex descriptor if necessary
        project.dependencies.select {|d| d.group == 'third-party' || d.group =='developer'}.each do |dep|
          # install the versioned third party gem if necessary
          if not is_installed? dep
            if dep.version == 'latest'
              Kudu.ui.info "Installing latest #{dep.name}"
              Kudu.ui.info `gem install -f --no-ri --no-rdoc #{dep.name}`.chomp
            else
              Kudu.ui.info "Installing #{dep.name}-#{dep.version}"
              Kudu.ui.info `gem install -f --no-ri --no-rdoc #{dep.name} --version \'#{dep.version}\'`.chomp
            end
          else
            msg = "Already installed, skipping #{dep.name}, #{dep.version}"
            Kudu.ui.info msg
          end
        end
      end
    end

    def is_installed? dep
      begin
        if (dep.version =='latest')
          Gem::Specification.find_by_name(dep.name)
        else
          Gem::Specification.find_by_name(dep.name, dep.version)
        end
        true
      rescue Gem::LoadError 
        false
      end
    end
  end

end
