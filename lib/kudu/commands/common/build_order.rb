module Kudu

  class CLI < Thor

    desc "build-order", "print version of named gem"
    method_option :name, :aliases => "-n", :type => :string, :required=>true, :desc => "project name"
    def build_order
      project = KuduProject.project(options[:name])
      project.dependencies.each{ |p| printf "%-40s%-40s\n", p.name, p.group }
    end

  end

end
