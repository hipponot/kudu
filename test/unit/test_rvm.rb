require 'test/unit'
require 'rvm'
require 'etc'

require_relative '../../lib/kudu'
require_relative '../../lib/kudu/cli'
require_relative '../../lib/kudu/rvm_util'
require_relative '../../lib/kudu/capture_stdout'

class TestRVM < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
  end
  

  def ignore_test_perf
    start = Time.now
    current = RVM.current 
    current.gemset.create 'blah'
    current.gemset.use! 'blah'
    10.times {
      `gem install json -f --no-ri --no-rdoc`
      `gem uninstall json`
    }
    out1 = `rvm @blah do gem list`
    current.gemset.delete 'blah'

    puts "elapsed #{Time.now - start}"
    start = Time.now
    `rvm gemset create blah`
    10.times {
      `rvm @blah do gem install json -f --no-ri --no-rdoc`
      `rvm @blah do gem uninstall json`
    }
    out2 = `rvm @blah do gem list`
    `rvm --force gemset delete blah`
    puts "elapsed #{Time.now - start}"    
  end

end


