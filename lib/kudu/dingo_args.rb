require 'json'
require 'optparse'

class KuduArgs

  attr_reader :options

  def initialize(argv)
    @library_path = []
    @options = {}
    @optparse = OptionParser.new do |opts|
      opts.banner = 'Usage: kudu [options]'
      opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
        @options[:verbose] = v
      end
      # Apply standard issue naming conventions - gems are snakecase, modules are camelcase
      opts.on('-m', '--module MODULE', 'Module name') do |module_name|
        @options[:module_name] = module_name
      end
      opts.on('-n', '--name NAME', 'Required - gem name') do |name|
        if name.downcase != name
          puts 'WARNING - Downcasing gem name to match convention'
        end
        @options[:name] = name.downcase
        @options[:module_name] = name.camel_case if @options[:module_name].nil?
      end
    end
    @optparse.parse!(argv)
  end

  def gitroot
    `git rev-parse --show-toplevel`.chomp
  end

  def template_dir
    File.join(gitroot, 'templates')
  end

  def valid_command_line_or_abort(cmd)
    valid_command_or_abort(cmd)
    valid_switches_or_abort(cmd)
  end

  COMMANDS = ['version', 'create-gem', 'build-order', 'rebuild-dependencies', 'gem-list', 'third-party-dependencies', 'in-house-dependencies']
  def valid_command_or_abort(cmd)
    abort "kudu: invalid command -- #{cmd}" unless COMMANDS.include?(cmd)
  end

  REQUIRED = {      
    'create-gem'=> [:name, :module_name],
    'build-order' => [],
    'rebuild-dependencies' => [],
    'gem-list' => [],
    'third-party-dependencies' => [],
    'in-house-dependencies' => [],
    'version' =>[]
  }
  def valid_switches_or_abort(cmd)
    missing_switches = []
    REQUIRED[cmd].each do |opt|
      if @options[opt].nil?
        missing_switches << opt
      end
    end
    unless missing_switches.empty?
      puts "Missing switches: #{missing_switches.map(&:to_s)}"
      abort @optparse.to_s
    end
  end

  # figure out a meta-programming way to add these methods  
  def module_name
    @options[:module_name]
  end

  def verbose
    @options[:verbose]
  end

  def name
    @options[:name]
  end

  def name=(name)
    @options[:name] = name
    @options[:module_name] = name.camel_case if @options[:module_name].nil?
  end


end
