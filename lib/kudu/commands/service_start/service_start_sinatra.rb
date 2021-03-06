require_relative '../../rvm_util'

module Kudu

  class ServiceStartSinatra

    def initialize(options)
      Kudu.rvm_use options[:repo]
      ENV['USER'] == 'vagrant' ? `shotgun -o 0.0.0.0 -p #{options[:port]}` : `shotgun -p #{options[:port]}` 
    end

  end

end
