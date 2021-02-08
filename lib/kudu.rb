require_relative "kudu/ui"

def is_installed? gem
  begin
    Gem::Specification.find_by_name(gem)
    true
  rescue Gem::LoadError
    false
  end
end

def install_require(gem, version)
  unless is_installed?(gem)
    system("gem install #{gem} -v #{version} -N")
    Gem.clear_paths
  end
  require gem
end

require 'fileutils'
require 'yaml'

install_require 'thor', '1.0.1'
install_require 'rvm', '1.11.3.9'
install_require 'erubis', '2.7.0'

module Kudu

  class << self
    attr_writer :ui
    def ui
      @ui ||= UI.new
    end
  end

end

