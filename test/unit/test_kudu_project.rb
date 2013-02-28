require 'test/unit'

require_relative '../../lib/kudu/kudu_project.rb'

class TestKuduProject < Test::Unit::TestCase
  
  def setup
  end
  
  def teardown
  end
  
  def test_kudu_project
   assert_nothing_raised { Kudu::KuduProject.new(File.join(File.dirname(__FILE__), 'kudu.yaml.test')) }
  end
  
end


