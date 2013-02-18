require 'etc'
require 'test/unit'

require_relative '../../lib/kudu'
require_relative '../../lib/kudu/cli'
require_relative '../../lib/kudu/rvm_util'
require_relative '../../lib/kudu/capture_stdout'
require_relative 'create_sample_projects'

class TestKudu < Test::Unit::TestCase

  include CreateSampleProjects

  def setup
    create_sample_projects 'sample_projects'
    create_sample_projects_in_namespace 'sample_projects_in_namespace'
  end

  def teardown
    remove_sample_projects 'sample_projects'    
    remove_sample_projects 'sample_projects_in_namespace'    
  end

  def test_version
    out = capture_stdout  { Kudu::CLI.start ['version'] }
    assert(out.string.strip == '0.0.1')
  end


  def test_build
    # Using a ruby 'here' document for capturing long string literal
    capture_stdout  { Kudu::CLI.start ['build', '-n', 'a', '-d', '-f', '-u', 'some_user'] }    
  end

  def test_skip_unchanged
    # Using a ruby 'here' document for capturing long string literal
    capture_stdout  { Kudu::CLI.start ['build', '-n', 'a', '-d', '-f', '-u', 'some_user'] }    
    out = capture_stdout  { Kudu::CLI.start ['build', '-n', 'a', '-d', '-f', '-u', 'some_user'] }    
  end

end


  
