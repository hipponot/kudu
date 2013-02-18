require 'test/unit'
require_relative '../../lib/kudu/util.rb'

class TestUtil < Test::Unit::TestCase

  def setup

  end

  def test_camel_case
    assert("foo_bar".camel_case == "FooBar")
  end

  def test_gitroot
    assert(File.exist?(File.join(Kudu.gitroot, '.git')))
  end
  
  def test_source_hash
    assert_nothing_raised { Kudu.source_hash(Kudu.gitroot) }
  end

end


