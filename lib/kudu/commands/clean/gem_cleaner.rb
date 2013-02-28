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
          Kudu.ui.info `rvm @#{options[:repo]} do gem uninstall -I -q -x #{project.name}`.chomp
          if options[:'more-clean'] || options[:nuke]
            project.dependencies.each do |dep|
              if dep.group == 'third-party'
                if dep.version == 'latest'
                  Kudu.ui.info `rvm @global do gem uninstall  -I -q -x #{dep.name}`.chomp
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
