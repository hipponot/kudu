require 'rvm'

require_relative '../../rvm_util'
require_relative '../../dependency_graph'
require_relative '../../ui'
require_relative '../../kudu_project'

module Kudu

  module GemCleaner

    def initialize(options, project)
      Kudu.with_logging(self, __method__) do
        current = Dir.pwd
        begin
          Kudu.rvm_use options[:repo]
          Kudu.ui.info "cleaning #{project.name}"
          Dir.chdir(project.directory)
          `rm -rf build`
          return if options[:local]
          Kudu.ui.info "uninstalling #{project.name} #{project.version}"
          if Kudu.is_installed? project.name, project.version
            cmd = "gem uninstall -I -x -q -v #{project.version} #{project.name}"
            Kudu.ui.info cmd
            Kudu.ui.info `#{cmd}`.chomp
            Kudu.ui.info `gem uninstall -I -x -q -v #{project.version} #{project.name}`.chomp
            # cleans up all version
            Kudu.ui.info `gem cleanup #{project.name}`
          end
          if options[:'more-clean'] || options[:nuke]
            project.dependencies.each do |dep|
              if /third-party|developer/ =~ dep.group
                if dep.version == 'latest' or /~>/ =~ dep.version
                  Kudu.ui.info cmd
                  cmd = "rvm @global do gem uninstall  -I -q -x #{dep.name}".chomp
                  Kudu.ui.info `#{cmd}`.chomp
                else
                  Kudu.ui.info `rvm @global do gem uninstall  -I -q -x #{dep.name} -v #{dep.version}`.chomp
                end
              end
            end
          end
          if options[:'nuke']
            Kudu.ui.info "Deleting @#{options[:repo]} gemset"
            RVM.gemset.delete(options[:repo])
            Kudu.ui.info "Deleting the @global gemset"
            RVM.gemset.delete("global") 
          end
        ensure
          Dir.chdir(current)
        end
      end
    end

  end
end
