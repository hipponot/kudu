require 'rvm'
require 'etc'

require_relative '../../error'
require_relative '../../rvm_util'

module Kudu

  class CLI < Thor
    if ENV['USER'] == 'vagrant'
      desc "shotgun", "rvm use @user; shotgun -o 0.0.0.0"  
    else
      desc "shotgun", "rvm use @user; shotgun" 
    end
    method_option :user, :aliases => "-u", :type=>:string, :required=>false, :default=>Etc.getlogin(),  :desc => "User defaults to $USER"
    method_option :verbose, :aliases => "-v", :type=>:boolean, :required=>false, :default=>false,  :desc => "Verbose output"
    def shotgun
      Kudu.verbose = options[:verbose]
    	Kudu.rvm_use options[:user]
      ENV['USER'] == 'vagrant' ? `shotgun -o 0.0.0.0` : `shotgun` 
    end
  end

end
