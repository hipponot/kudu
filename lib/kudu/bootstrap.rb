module Kudu

  class Bootstrap

    class << self
      def init(argv)
        unless argv[0] == "bootstrap"
          if File.exists?(File.join(ENV['HOME'],'.kudu_bootstrap'))
            return
          else
            puts 'Please run kudu bootstrap'
            puts 'usage: kudu bootstrap'
            exit(0)
          end
        end
        
        File.open(File.join(ENV['HOME'], '.kudu_bootstrap'), "w") { |f| f.puts true }          
        ['rvm','builder','rack','shotgun','sinatra','sinatra-synchrony','erubis','thor','rgl', 'sqlite3', 'RocketAMF'].each do |gem|
          unless is_installed gem
	          cmd = "gem install -f -N #{gem}"
            puts cmd
	          puts `#{cmd}`
          else
            puts "Already installed #{gem}"
          end
        end
        exit(0)
      end

      def is_installed gem
        begin
          Gem::Specification.find_by_name(gem)
          true
        rescue Gem::LoadError 
          false
        end
      end

    end

  end
end
