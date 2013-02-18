require_relative '../../dependency_graph'

module Kudu
  # need to 
  class CLI < Thor
    desc "build-order", "Build order of in-house gems"
    def build_order
      puts DependencyGraph.build_order.inspect
    end
  end


end
