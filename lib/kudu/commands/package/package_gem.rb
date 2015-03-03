require 'rvm'
require 'etc'

require_relative '../../error'
require_relative '../../util'
require_relative '../../rvm_util'
require_relative '../../dependency_graph'
require_relative '../../ui'
require_relative '../../kudu_project'

module Kudu
  class PackageGem

    def initialize(options, project, cli)

      # do a clean production build with dependencies
      clean_options = { name:project.name, :dependencies=>true, :repo=>'default', :local=>true}
      cli.invoke :clean, nil, clean_options
      build_options = { 
        :name=>project.name, 
        :install=>false, 
        :ruby=>options[:ruby], 
        :force=>true, 
        :'skip-third-party'=>true, 
        :repo=>'default', 
        :production=>options[:production],
        :dependencies=>true, 
        :'bump-version'=>options[:'bump-version'] 
      }
      Kudu.ui.info "Building with options #{build_options}"
      cli.invoke :build, nil, build_options

      # create package directions
      package_dir = File.join(options[:'package-dir'])
      package_name = "#{project.name}-#{project.version}"
      target = File.join(package_dir, package_name)
      tarball_name = "#{package_name}.tar.gz"
      tarball = File.join(package_dir, tarball_name)
      if ( File.exist?(target) || File.exist?(tarball) ) and not options[:force]
        Kudu.ui.error("File exists #{target}.  Use --force to overwrite.. punting")
        exit(1)
      elsif options[:force]
        FileUtils.rm_rf(target)
        FileUtils.rm_rf(tarball)
      end
      FileUtils.mkdir_p(target)
      FileUtils.cp_r(File.join(project.directory, 'build/.'), target)      

      # add in-house dependencies to the package
      project.dependencies('in-house').each do |dep|
        dep = KuduProject.project(dep.name)
        FileUtils.cp_r(File.join(dep.directory, 'build/.'), target)
      end

      # installer
      outfile = File.join(target, "install.rb")
      template = File.join(Kudu.template_dir, "install-gem.rb.erb")
      ErubisInflater.inflate_file_write(template, {}, outfile)
      `chmod +x #{outfile}`
      # third party
      File.open(File.join(target,"third_party.yaml"), 'w') {
        |f| f.write(project.dependencies('third-party').map {|d| {name:d.name, version:d.version} }.to_yaml) 
      }
      # tarball
      `cd #{package_dir}; tar cf #{package_name}.tar #{File.basename(target)}`
      `cd #{package_dir}; gzip -9 -f #{package_name}.tar`
      # cleanup
      FileUtils.rm_rf(target)
      if File.exist?(tarball)
        Kudu.ui.info("Wrote package #{tarball}")
      else
        Kudu.ui.error("Something went horribly wrong, can't find #{tarball}")
      end
    end

  end # PackageSinatra
end # Kudu
