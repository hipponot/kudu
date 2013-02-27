require 'tsort'

require_relative 'ui'
require_relative 'git_util'
require_relative 'kudu_project'

module Kudu

  class DependencyGraph

    # Directed graph
    include TSort
    def tsort_each_child (node, &block)
      if graph[node].nil?
        puts 'yoda'
      end
      graph[node].each(&block)
    end
    def tsort_each_node (&block)
      graph.each_key(&block)
    end

    alias_method :topological_sort, :tsort

    attr_reader :graph
    def initialize()
      @graph = initialize_graph
    end

    def build_order name=nil
      if name.nil?
        rval = tsort.map { |k| project_lookup[k] }
      else
        d = []
        each_strongly_connected_component_from(vertex_lookup[name]) do |c|
          d.concat c
        end
        rval = d.map{ |k| project_lookup[k] }
      end
      rval.compact.uniq
    end
    
    def project_lookup
        @project_lookup ||= {}
    end

    private

    def vertex_lookup
        @vertex_lookup ||= {}
    end

    def initialize_graph(rootdir = Kudu.gitroot)
      graph = {}
      KuduProject.projects.each do |name, project|
        project.publications.each do |pub|
          # in-house nodes in the dependency graph are implictly versioned 'latest'
          v = {:name=>pub.name, :group=>pub.group, :type=>pub.type}
          v[:version] = pub.group == 'in-house' ? 'latest' : pub.version
          project_lookup[v] = project
          vertex_lookup[project.name] = v
          graph[v] = []
          project.dependencies.each do|dep| 
            unless graph.has_key?(dep) 
              graph[dep.to_hash] = []
            end
            graph[v] << dep.to_hash
          end
        end
      end
      graph
    end

  end

end
