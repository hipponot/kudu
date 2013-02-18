require 'rvm'
require_relative 'util'

module Kudu
  class << self

    def list_gem(gemset)
      begin
        RVM.gemset.use! gemset
        `gem list -d`.split(/(?=^\S)/).each do |g|
          details = g.split(/\r?\n/)
          name = details[0]
          gemset = details.find { |e| /Installed/ =~ e }.split('/').last
          printf "%-40s gemset:%s\n", name, gemset
        end
      ensure
        RVM.gemset.use! 'default'
      end
    end
 
    def rvm_use gemset
      Kudu.with_logging(self, __method__, gemset) do
        RVM.gemset.create gemset
        RVM.gemset.use! gemset
      end
    end

  end
end
