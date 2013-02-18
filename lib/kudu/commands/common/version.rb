require_relative '../../version'

module Kudu

  class CLI < Thor

    desc "version", "print version"
    def version
      puts VERSION
    end

  end

end
