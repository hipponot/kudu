#!/usr/bin/env ruby

 require 'fileutils'

require_relative '../../lib/kudu'
require_relative '../../lib/kudu/cli'
require_relative '../../lib/kudu/capture_stdout'

module CreateSampleProjects

  def create_sample_projects_in_namespace dir='sample_projects'
    begin
      current = Dir.pwd
      FileUtils.mkdir_p(dir)
      Dir.chdir(dir)
      capture_stdout  { Kudu::CLI.start ['create-project', '-f', '-n=kudu_a', '-d', '{name:%q{kudu_b}, group:%q{in-house}, type:%q{gem}}'] }
      capture_stdout  { Kudu::CLI.start ['create-project', '-f', '-n=kudu_b', '-d', '{name:%q{kudu_c}, group:%q{in-house}, type:%q{gem}}'] }
      capture_stdout  { Kudu::CLI.start ['create-project', '-f', '-n=kudu_c', '-d', '{name:%q{kudu_d}, group:%q{in-house}, type:%q{gem}}',
                                                                                    '{name:%q{kudu_e}, group:%q{in-house}, type:%q{gem}}'] }
      capture_stdout  { Kudu::CLI.start ['create-project', '-f', '-n=kudu_d', '-d', '{name:%q{json},   version:%q{1.7.5}, type:%q{gem}, group:%q{third-party}}'] }
      capture_stdout  { Kudu::CLI.start ['create-project', '-f', '-n=kudu_e', '-d', '{name:%q{erubis}, version:%q{2.7.0}, type:%q{gem}, group:%q{third-party}}'] }
    end
  end

  def create_sample_projects dir='sample_projects'
    begin
      current = Dir.pwd
      FileUtils.mkdir_p(dir)
      Dir.chdir(dir)
      capture_stdout  { Kudu::CLI.start ['create-project', '-f', '-n=a', '-d', '{name:%q{b}, group:%q{in-house}, type:%q{gem}}'] }
      capture_stdout  { Kudu::CLI.start ['create-project', '-f', '-n=b', '-d', '{name:%q{c}, group:%q{in-house}, type:%q{gem}}'] }
      capture_stdout  { Kudu::CLI.start ['create-project', '-f', '-n=c', '-d', '{name:%q{d}, group:%q{in-house}, type:%q{gem}}',
                                                                               '{name:%q{e}, group:%q{in-house}, type:%q{gem}}'] }
      capture_stdout  { Kudu::CLI.start ['create-project', '-f', '-n=d', '-d', '{name:%q{json},   version:%q{1.7.5}, type:%q{gem}, group:%q{third-party}}'] }
      capture_stdout  { Kudu::CLI.start ['create-project', '-f', '-n=e', '-d', '{name:%q{erubis}, version:%q{2.7.0}, type:%q{gem}, group:%q{third-party}}'] }
    ensure
      Dir.chdir(current)
    end
  end

  def remove_sample_projects dir='sample_projects'
    FileUtils.rm_rf(dir)
  end
end

# Entry point to generate projects from cli
if __FILE__ == $0
  include CreateSampleProjects
  unless ARGV[0].is_a?(String)
    puts 'usage create_sample_projects.rb [directory]'
    exit(0)
  end
  create_sample_projects_in_namespace ARGV[0]
end