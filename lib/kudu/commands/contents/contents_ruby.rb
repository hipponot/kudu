module Kudu

  class CLI < Thor
    
    desc "contents", "print contents of installed gems"
    method_option :gemset, :aliases => "-g", :type=>:string, :required=>false, :default=>Etc.getlogin(),  :desc => "Gemset"
    method_option :name, :aliases => "-n", :type=>:string, :required=>true, :desc => "Gem name"
    def contents
      list_contents options[:gemset], options[:name]
    end
    
    private
    
    def list_contents(gemset, name)
      puts `rvm @#{gemset} do gem contents #{name}`
    end

  end

end
