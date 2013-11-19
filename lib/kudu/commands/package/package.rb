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

    method_option :names, :aliases => "-n", :type => :array, :required=>true, :default=>["woot_db", "wm_api", "wm_web"], :desc => "project names"
    method_option :package, :aliases => "-p", :type => :array, :required=>true, :default=>"/Volumes/shared/pool/pkgs/wootmath_gems", :desc => "package path"
    method_option :force, :aliases => "-f", :type => :boolean, :required=>false, :default=>false, :desc => "overwrite existing package"
    def package
      Kudu.with_logging(self, __method__) do
        projects = []
        third_party = []
        in_house = []
        options[:names].each do |name|
          projects << project = KuduProject.project(name)
          third_party.concat project.dependencies('third-party')
          in_house.concat project.dependencies('in-house')
        end
        # remove duplicates
        [third_party, in_house].each{ |a| a.uniq!{ |p| [ p.name, p.version] }}
        build_package(projects, in_house, third_party)
      end
    end

    private

    def build_package(projects, in_house, third_party)
      package = File.join(options[:package])
      tarball = "#{package}.tar.gz"
      if ( File.exist?(package) || File.exist?(tarball) ) and not options[:force]
        Kudu.ui.error("File exists #{package}.  Use --force to overwrite.. punting")
        exit(1)
      elsif options[:force]
        FileUtils.rm_rf(package)
        FileUtils.rm_rf(tarball)
      end
      Dir.mkdir(package)
      [projects, in_house].flatten.each do |project|
        # so we can access project.directory
        project = KuduProject.project(project.name)
        target_dir = File.join(package, project.name)
        Dir.mkdir(target_dir) unless File.directory?(target_dir)
        build_options = { name:project.name, force:true}
        cmd = "kudu clean -n #{project.name}"
        puts `#{cmd}`
        cmd = "kudu build -n #{project.name}"
        puts `#{cmd}`
        FileUtils.cp_r(File.join(project.directory, 'build/.'), target_dir)
      end
      # installer
      outfile = File.join(package, "install.rb")
      template = File.join(Kudu.template_dir, "install.rb.erb")
      ErubisInflater.inflate_file_write(template, {}, outfile)
      `chmod +x #{outfile}`
      # third party
      File.open(File.join(package,"third_party.yaml"), 'w') {
        |f| f.write(third_party.map {|d| {name:d.name, version:d.version} }.to_yaml) 
      }
      # tarball
      `cd #{File.join(File.dirname(package))}; tar cvf #{File.basename(package)}.tar #{File.basename(package)}`
      `gzip -f #{package}.tar`
      # cleanup
      FileUtils.rm_rf(package)
      if File.exist?(tarball)
        Kudu.ui.info("Wrote package #{tarball}")
      else
        Kudu.ui.error("Something went horribly wrong, can't find #{tarball}")
      end
    end
  end
end
