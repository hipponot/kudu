require 'rvm'
require 'etc'

require_relative '../../error'
require_relative '../../util'
require_relative '../../rvm_util'
require_relative '../../dependency_graph'
require_relative '../../ui'
require_relative '../../kudu_project'

module Kudu
  class PackageSinatra

    def initialize(options, project, cli)

      # do a clean production build with dependencies
      clean_options = { name:project.name, :dependencies=>true, :repo=>'default', :local=>true}
      cli.invoke :clean, nil, clean_options
      build_options = { 
        :name=>project.name, 
        :install=>false, 
        :ruby=>options[:ruby], 
        :force=>true, 
        :skip_third_party=>true, 
        :repo=>'default', 
        :dependencies=>true, 
        :num_workers=>options[:num_workers],
        :version=>options[:version] 
      }
      Kudu.ui.info "Building with options #{build_options}"
      cli.invoke :build, nil, build_options

      # create package directions
      package_dir = File.join(options[:package_dir])
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
      begin
        FileUtils.mkdir_p(target)
      rescue Exception=>e
        Kudu.ui.error("Failed to create the directory #{target}")
        exit(1)
      end
      FileUtils.cp_r(File.join(project.directory, 'build/.'), target)      

      # add in-house dependencies to the package
      project.transitive_dependencies('in-house').each do |dep|
        dep = KuduProject.project(dep.name)
        FileUtils.cp_r(File.join(dep.directory, 'build/.'), target)
      end

      # Dead Code
      #
      #-- Static file delivery for sinatra apps (that have an appropriately named lib/public/static_src/<API>/ dir):
      # sinatra_static_src_dir = File.join  project.directory, %W(lib public static_src #{project.name})
      # if File.directory? sinatra_static_src_dir
      #   static_staging_dir = options[:static_dir]
      #   tgt_dir = File.join static_staging_dir, %W( #{project.name} #{project.version} ) 
      #   # ToDo - reenable when we are doing production builds
      #   if false and File.directory? tgt_dir
      #     puts "Static content directory already exists: #{tgt_dir}\n --Leaving existing content as is."
      #   else
      #     puts "Delivering static content to #{tgt_dir}"
      #     FileUtils.mkdir_p tgt_dir, :verbose => true
      #     pwd = Dir.getwd
      #     puts "cd #{sinatra_static_src_dir}"
      #     Dir.chdir sinatra_static_src_dir
      #     FileUtils.cp_r Dir.glob("*"), tgt_dir, :verbose => true
      #     puts "cd #{pwd}"
      #       Dir.chdir pwd 
      #   end
      # end

      # installer
      outfile = File.join(target, "install.rb")
      template = File.join(Kudu.template_dir, "install-sinatra.rb.erb")
      ErubisInflater.inflate_file_write(template, {}, outfile)
      `chmod +x #{outfile}`
      # third party
      File.open(File.join(target,"third_party.yaml"), 'w') {
        |f| f.write(project.transitive_dependencies('third-party').map {|d| {name:d.name, version:d.version} }.to_yaml) 
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
