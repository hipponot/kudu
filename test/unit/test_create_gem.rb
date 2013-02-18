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
    create_sample_projects 'sample_no_namespace'
    create_sample_projects_in_namespace 'sample_in_namespace'
  end
  
  def teardown
    remove_sample_projects 'sample_no_namespace'
    remove_sample_projects 'sample_in_namespace'
  end

  def test_version
    file = File.join(Dir.pwd , 'sample_in_namespace/cws_a/lib/cws_a/version.rb')
    puts file
    load(file)
    assert(Cws::A::VERSION == '0.0.1')
    file = File.join(Dir.pwd, 'sample_no_namespace/a/lib/a/version.rb')
    puts file 
    load(File.join(Dir.pwd, 'sample_no_namespace/a/lib/a/version.rb'))
    assert(A::VERSION == '0.0.1')
  end

end


  
