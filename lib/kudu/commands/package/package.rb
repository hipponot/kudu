require 'rvm'
require 'etc'
require 'fileutils'
require 'yaml'

require_relative '../../error'
require_relative '../../util'
require_relative '../../ui'
require_relative '../../kudu_project'
require_relative '../../dependency_graph'

module Kudu

  class CLI < Thor

    desc "package", "Package project"

    method_option :name, :aliases => "-n", :type => :string, :required=>true, :desc => "project name"
    method_option :'package-dir', :aliases => "-p", :type => :string, :required=>true, :default=>"/Volumes/shared/pool/pkgs", :desc => "package directory"
    method_option :force, :aliases => "-f", :type => :boolean, :required=>false, :default=>false, :desc => "overwrite existing package"
    def package
      Kudu.with_logging(self, __method__) do
        project = KuduProject.project(options[:name])
        build_package(project)
      end
    end

    private

    def package_version(project, in_house, third_party)
      [projects, in_house, third_party].flatten.each do |project|
        # so we can access project.directory
        project = KuduProject.project(project.name)
      end
    end

    def build_package(project)

      package_dir = File.join(options[:'package-dir'])
      package_name = "#{project.name}-#{project.version}"
      target = File.join(package_dir, package_name)
      tarball_name = "#{package_name}.tar.gz"
      tarball = File.join(package_dir, tarball_name)
      if ( File.exist?(target) || File.exist?(tarball) ) and not options[:force]
        Kudu.ui.error("File exists #{package}.  Use --force to overwrite.. punting")
        exit(1)
      elsif options[:force]
        FileUtils.rm_rf(target)
        FileUtils.rm_rf(tarball)
      end
      Dir.mkdir(target)

      # do a clean production build with dependencies
      clean_options = { name:project.name, :dependencies=>true, :repo=>'default'}
      invoke :clean, nil, clean_options
      build_options = { :name=>project.name, :force=>true, :'skip-third-party'=>true, :repo=>'default', :dependencies=>true, :production=>true }
      invoke :build, nil, build_options
      FileUtils.cp_r(File.join(project.directory, 'build/.'), target)      

      # add in-house dependencies to the package
      project.dependencies('in-house').each do |dep|
        dep = KuduProject.project(dep.name)
        FileUtils.cp_r(File.join(dep.directory, 'build/.'), target)
      end

      #-- Static file delivery for sinatra apps (that have an appropriately named lib/public/static/xxx/src dir):
      sinatra_static_src_dir = File.join  project.directory, %W(lib public static #{project.name} src)
      if File.directory? sinatra_static_src_dir
        static_staging_dir = '/Volumes/shared/pool/www-static'
        tgt_dir = File.join static_staging_dir, %W( #{project.name} #{project.version} ) 
        if File.directory? tgt_dir
          puts "Static content directory already exists: #{tgt_dir}\n --Leaving existing content as is."
        else
          puts "Delivering static content to #{tgt_dir}"
          FileUtils.mkdir_p tgt_dir, :verbose => true
          pwd = Dir.getwd
          puts "cd #{sinatra_static_src_dir}"
          Dir.chdir sinatra_static_src_dir
          FileUtils.cp_r Dir.glob("*"), tgt_dir, :verbose => true
          puts "cd #{pwd}"
            Dir.chdir pwd 
        end
      end

      # installer
      outfile = File.join(package, "install.rb")
      template = File.join(Kudu.template_dir, "install.rb.erb")
      ErubisInflater.inflate_file_write(template, {}, outfile)
      `chmod +x #{outfile}`
      # third party
      File.open(File.join(package,"third_party.yaml"), 'w') {
        |f| f.write(project.dependencies('third_party').map {|d| {name:d.name, version:d.version} }.to_yaml) 
      }
      # tarball
      `cd #{File.join(File.dirname(package))}; tar cvf #{File.basename(package)}.tar #{File.basename(package)}`
      `gzip -9 -f #{package}.tar`
      # cleanup
      FileUtils.rm_rf(target)
      if File.exist?(tarball)
        Kudu.ui.info("Wrote package #{tarball}")
      else
        Kudu.ui.error("Something went horribly wrong, can't find #{tarball}")
      end
    end
  end
end
