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
      capture_stdout  { Kudu::CLI.start ['create-gem', '-f', '--namespace=cws', '--name=a', '-d', '{name:%q{b}, version:%q{0.0.1}, group:%q{in-house}, namespace:%q{cws}}'] }
      capture_stdout  { Kudu::CLI.start ['create-gem', '-f', '--namespace=cws', '--name=b', '-d', '{name:%q{c}, version:%q{0.0.1}, group:%q{in-house}, namespace:%q{cws}}'] }
      capture_stdout  { Kudu::CLI.start ['create-gem', '-f', '--namespace=cws', '--name=c', '-d', '{name:%q{d}, version:%q{0.0.1}, group:%q{in-house}, namespace:%q{cws}}', 
                                                                                                   '{name:%q{e}, version:%q{0.0.1}, group:%q{in-house}, namespace:%q{cws}}'] }
      capture_stdout  { Kudu::CLI.start ['create-gem', '-f', '--namespace=cws', '--name=d', '-d', '{name:%q{json},   version:%q{1.7.5}, group:%q{third-party}}'] }
      capture_stdout  { Kudu::CLI.start ['create-gem', '-f', '--namespace=cws', '--name=e', '-d', '{name:%q{erubis}, version:%q{2.7.0}, group:%q{third-party}}'] }
    ensure
      Dir.chdir(current)
    end
  end

  def create_sample_projects dir='sample_projects'
    begin
      current = Dir.pwd
      FileUtils.mkdir_p(dir)
      Dir.chdir(dir)
      capture_stdout  { Kudu::CLI.start ['create-gem', '-f', '--name=a', '-d', '{name:%q{b}, version:%q{0.0.1}, group:%q{in-house}}'] }
      capture_stdout  { Kudu::CLI.start ['create-gem', '-f', '--name=b', '-d', '{name:%q{c}, version:%q{0.0.1}, group:%q{in-house}}'] }
      capture_stdout  { Kudu::CLI.start ['create-gem', '-f', '--name=c', '-d', '{name:%q{d}, version:%q{0.0.1}, group:%q{in-house}}', 
                                                                                '{name:%q{e}, version:%q{0.0.1}, group:%q{in-house}}'] }
      capture_stdout  { Kudu::CLI.start ['create-gem', '-f', '--name=d', '-d', '{name:%q{json},   version:%q{1.7.5}, group:%q{third-party}}'] }
      capture_stdout  { Kudu::CLI.start ['create-gem', '-f', '--name=e', '-d', '{name:%q{erubis}, version:%q{2.7.0}, group:%q{third-party}}'] }
    ensure
      Dir.chdir(current)
    end
  end

  def remove_sample_projects dir='sample_projects'
    FileUtils.rm_rf(dir)
  end

end
