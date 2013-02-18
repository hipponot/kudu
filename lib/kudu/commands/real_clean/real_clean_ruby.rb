require 'rvm'
require 'etc'
require_relative '../../error'

module Kudu

  class CLI < Thor

    desc "real-clean", "Delete user and global gemset"
    method_option :user, :aliases => "-u", :type=>:string, :required=>false, :default=>Etc.getlogin(),  :desc => "Delete user gemset"
    method_option :global, :aliases => "-g", :type=>:boolean, :required=>false, :default=>false,  :desc => "Delete user global gemset"    
    def real_clean
      RVM.gemset.delete(options[:user])
      RVM.gemset.delete("global") if options[:global]
    end

  end

end
