require 'test/unit'
require 'fileutils'

require_relative '../../lib/kudu'
require_relative '../../lib/kudu/cli'
require_relative '../../lib/kudu/capture_stdout'
require_relative '../../lib/kudu/dependency_graph.rb'
require_relative 'create_sample_projects'

class TestDependencyGraph < Test::Unit::TestCase

  include CreateSampleProjects

  def setup
    @pwd = Dir.pwd
    create_sample_projects File.join(@pwd,'sample_projects')
    create_sample_projects_in_namespace File.join(@pwd, 'sample_projects_in_namespace')
  end

  def teardown
    remove_sample_projects File.join(@pwd,'sample_projects')
    remove_sample_projects File.join(@pwd,'sample_projects_in_namespace')
  end

  def test_dependency_graph
   g = Kudu::DependencyGraph.new
   assert( (g.build_order 'kudu_a').map {|p| p.name } == ['kudu_d', 'kudu_e', 'kudu_c', 'kudu_b', 'kudu_a'])
  end

=begin
  def test_third_party
    deps = Kudu::DependencyGraph.third_party('a',false)
    assert(deps == [])
    deps = Kudu::DependencyGraph.third_party('d')
    assert(deps = [{:name => 'json', :version =>'1.7.5', :group=>'third-party'}])
  end

  def test_in_house
    deps = Kudu::DependencyGraph.in_house('a').map { |d| d[:name] }
    assert( deps == ['d', 'e', 'c', 'b', 'a'])
  end

  def test_in_house_in_namespace
    deps = Kudu::DependencyGraph.in_house('cws_a').map { |d| d[:namespace] + "_" + d[:name] }
    assert( deps == ['cws_d', 'cws_e', 'cws_c', 'cws_b', 'cws_a'])
  end
=end

end


