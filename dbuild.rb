require 'rvm'
require 'etc'
require 'rubygems/builder'
require 'rubygems/installer'

require 'ruby-prof' unless RUBY_PLATFORM=='java'

require_relative '../error'
require_relative '../util'
require_relative '../rvm_util'
require_relative '../dependency_graph'
require_relative '../capture_stdout'
require_relative '../ui'

module Dingo

  class CLI < Thor

    desc "build", "Build gem"
    method_option :name, :aliases => "-n", :required=>false, :desc => "Gem name", :lazy_default => ""
    method_option :all, :aliases => "-a", :type => :boolean, :required=>false, :desc => "Build everything"
    method_option :gemspec, :aliases => "-g", :required=>false, :desc => "Gemspec file name", :lazy_default => ""
    method_option :'rebuild-dependencies', :aliases => "-d", :required => false, :desc => "Rebuild dependencies before building"
    method_option :force, :aliases => "-f", :type => :boolean, :required => false, :default => false,  :desc => "Force rebuild"
    method_option :profile, :aliases => "-p", :type =>:boolean, :required => false, :default => false,  :desc => "Profile build"
    method_option :user, :aliases => "-u", :type => :string, :required => false, :default=>Etc.getlogin(),  :desc => "User gemset name"
    method_option :ffsf, :aliases => "-s", :type => :boolean, :required => false, :default=>false,  :desc => "Fast fast super fast"
    
    # No ruby-prof in jruby 
    @profile = RUBY_PLATFORM == 'java' ? false : options[:profile] 
    
    def build
      Dingo.with_logging(self, __method__) do
        @force = options[:force] || options[:ffsf]
        @user = options[:user]
        @ffsf = options[:ffsf]
        @use_native = false
        name = options[:name] 
        gemspec = options[:gemspec]

        RubyProf.start if @profile
        Dingo.validate_standard_options(options)

        if options[:all]
          Dingo.each { |name| rebuild_dependencies(name) } 
          exit(0)
        end
        
        # Get name and gemspec from local directory or from -n or -g option
        name = name ? name : Dingo.get_name_from_gemspec(gemspec)        
        options[:'rebuild-dependencies'] ? rebuild_dependencies(name) : build_one(name)
        if @profile
          result = RubyProf.stop
          printer = RubyProf::GraphPrinter.new(result)
          printer.print(STDOUT)
        end
      end
    end

    private

    # Compares hash of local files not ignored by git with hash in
    # installed gem
    #
    def has_changed(vertex)
      Dingo.with_logging(self, __method__) do
        return @force if @force
        begin
          rootdir = File.dirname(DependencyGraph.gemspec(vertex))
          local_hash = Dingo.source_hash(rootdir)
          install_hash = installed_gem_source_hash(vertex)
          if local_hash != install_hash
            IO.write(File.join(rootdir, 'lib', name_from_vertex(vertex), 'sha1'), local_hash)
            return true
          end
          false
        rescue Exception => e
          Dingo.ui.error "Unknown artifact #{vertex.inspect}"
          raise BuildGemFailed, "Gem build failed: #{e.message}"
        end
      end
    end
    
    def rebuild_dependencies(name)
      Dingo.with_logging(self, __method__) do
        # Break this out as 2 loops to avoid multple (expensive) context
        # switches
        Dingo.rvm_use "global"
        DependencyGraph.in_house(name).each do |dep|
          install_third_party dep
        end
        Dingo.rvm_use @user
        DependencyGraph.in_house(name).each do |dep|
          build_gem(dep)
        end
      end
    end

    def build_one(name)
      Dingo.with_logging(self, __method__) do
        Dingo.rvm_use "global"
        install_third_party name
        Dingo.rvm_use @user
        build_gem name
      end
    end

    def name_from_vertex artifact
      Dingo.with_logging(self, __method__) do
        name = artifact[:namespace] ? artifact[:namespace] + "_" + artifact[:name] : artifact[:name]
      end
    end

    def version_from_vertex artifact
      Dingo.with_logging(self, __method__) do
        version = DependencyGraph.version(artifact)
      end
    end

    def install_third_party vertex
      Dingo.with_logging(self, __method__) do
        # Convert to full vertex descriptor if necessary
        vertex = DependencyGraph.vertex_from_name(vertex)
        DependencyGraph.third_party(vertex, false).each do |dep|
          # third party dependencies are an array or arrays [ [name, version]...]
          installed_versions = `gem list #{dep[:name]}`.scan(/(\d+\.\d+\.\d+)/).flatten
          # install the versioned third party gem if necessary
          if not is_installed dep
            if dep[:version].nil?
              Dingo.ui.info "Installing latest #{dep[:name]}"
              Dingo.ui.info `gem install -f --no-ri --no-rdoc #{dep[:name]}`.chomp
            else
              Dingo.ui.info "Installing #{dep[:name]}-#{dep[:version]}"
              Dingo.ui.info `gem install -f --no-ri --no-rdoc #{dep[:name]} --version \'#{dep[:version]}\'`.chomp
            end
          else
            msg = "Already installed, skipping #{dep[:name]}" 
            msg += " #{dep[:version]}" if dep[:version]
            Dingo.ui.info msg
          end
        end
      end
    end

    def is_installed dep
      begin
        Gem::Specification.find_by_name(dep[:name], dep[:version])
        true
      rescue Gem::LoadError 
        false
      end
    end

   

    def build_gem(vertex)
      Dingo.with_logging(self, __method__) do
        begin
          # Convert to full vertex descriptor if necessary
          vertex = DependencyGraph.vertex_from_name(vertex)
          unless has_changed(vertex)
            Dingo.ui.info "Already installed and no local changes, skipping #{vertex[:name]}:"
            return
          end
          gemspec = DependencyGraph.gemspec(vertex)
          current = Dir.pwd
          begin
            basedir = File.dirname(gemspec)
            Dir.chdir(basedir)
            builddir = File.join(basedir,'build')
            Dir.mkdir(builddir) unless File.directory?(builddir)
            if @use_native
              spec = Gem::Specification::load(gemspec)
              Gem.configuration.verbose = false
              gem = Gem::Builder.new(spec).build 
              installer = Gem::Installer.new(gem)
              out = installer.install() 
            else 
              `gem build #{gemspec}`
              gem = name_from_vertex(vertex) + '-' + version_from_vertex(vertex) + '.gem'
              FileUtils.mv File.join(basedir, gem), File.join(builddir, gem)
              Dir.chdir(builddir)
              `gem install -l -f --no-ri --no-rdoc #{gem}`
            end
            Dingo.ui.info "Installed #{gem} in group #{vertex[:group]}"
            ffsf(vertex) if @ffsf
          ensure
            Dir.chdir(current)
          end
        rescue Exception => e
          raise BuildGemFailed, "Gem build failed: #{e.message}"
        end
      end
    end

    def installed_gem_source_hash(vertex)
      Dingo.with_logging(self, __method__) do
        files = `gem contents #{name_from_vertex(vertex)} --version #{DependencyGraph.version(vertex)}`.split($/)
        files.each do |file|
          if file =~/sha1/
            sha1 = IO.read(file)
            return sha1
          end
        end
        return nil
      end                               
    end
    
    def ffsf(vertex)
      Dingo.with_logging(self, __method__) do
        full_name = DependencyGraph.full_name(vertex)
        targets = `gem contents #{full_name}`.split($/) 
        rootdir = File.dirname(DependencyGraph.gemspec(vertex))
        sources = targets.map { |f| rootdir + f.split(/#{full_name}-\d+\.\d+\.\d+/)[1] }
        for i in 0..sources.length-1
          cmd = "ln -F -s #{sources[i]} #{targets[i]}"
          system(cmd)
          print "FFSF made the following links:"
          Dingo.ui.cyan(targets[i].gsub(ENV['HOME'],'~'),false); print '->'; Dingo.ui.blue(sources[i].gsub(ENV['HOME'],'~'))
        end
      end
    end

  end

end
