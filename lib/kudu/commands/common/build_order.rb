require 'json'

module Kudu

  class CLI < Thor

    desc "build-order", "Print topological ordering of dependency graph"
    method_option :name, :aliases => "-n", :type => :string, :required=>true, :desc => "project name"
    def build_order
      dg = DependencyGraph.new
      dg.build_order(options[:name]).each do |p|
        printf "%-40s%-40s\n", p.name, p.group 
      end
    end

  end

end
