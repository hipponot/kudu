require 'thor'
require 'rubygems/user_interaction'
require 'rubygems/config_file'

require_relative 'require_relative_all'
require_relative_all 'commands/**/*.rb'

module Kudu
  class CLI < Thor
    include Thor::Actions

    def self.exit_on_failure?
      true
    end

    def initialize(*)
      super
      the_shell = (options["no-color"] ? Thor::Shell::Basic.new : shell)
      Kudu.ui = UI::Shell.new(the_shell)
      Kudu.ui.debug! if options["verbose"]
    end

    check_unknown_options!(:except => [:config, :exec])

    default_task :help
    class_option "no-color", :type => :boolean, :banner => "Disable colorization in output"
    class_option "verbose",  :type => :boolean, :banner => "Enable verbose output mode", :aliases => "-V"

  end
end
