module Kudu

  class CLI < Thor

    desc "list", "print list of installed gems"
    method_option :user, :aliases => "-u", :type=>:string, :required=>false, :default=>Etc.getlogin(),  :desc => "User gemset to list"
    def list
      list_gemset options[:user]
    end

    private

    def list_gemset gemset
      begin
        `rvm @#{gemset} do gem list -d`.split(/(?=^\S)/).each do |g|
          details = g.split(/\r?\n/)
          name = details[0]
          gemset_name = details.find { |e| /Installed/ =~ e }.split('/').last
          printf "%-40s gemset:%s\n", name, gemset_name
        end
      rescue
        Kudu.ui.error "Unknown gemset #{gemset}"        
      end
    end
    
  end
end
