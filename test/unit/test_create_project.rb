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
    create_sample_projects File.join(File.dirname(__FILE__),'sample_no_namespace')
    create_sample_projects_in_namespace File.join(File.dirname(__FILE__),'sample_in_namespace')
  end

  def teardown
    remove_sample_projects File.join(File.dirname(__FILE__),'sample_no_namespace')
    remove_sample_projects File.join(File.dirname(__FILE__),'sample_in_namespace')
  end

  def test_version
    Dir.glob("#{File.dirname(__FILE__)}/sample_in_namespace/**/version.rb") do |file|
      load(file)
      assert(Kudu::A::VERSION == '1.0.1')
    end
    Dir.glob("#{File.dirname(__FILE__)}/sample_no_namespace/**/version.rb") do |file|
      load(file)
      assert(A::VERSION == '1.0.1')
    end
  
  end

end


  
