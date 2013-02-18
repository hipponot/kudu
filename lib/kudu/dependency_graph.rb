require 'rgl/adjacency'
require 'rgl/dot'
require 'rgl/topsort'
require 'rgl/implicit'

require_relative 'util'

module Kudu

  class DependencyGraph

    class << self

      # Construct a dependency graph, with v.keys = [:name, :version, :group]
      def initialize_graph
        # Add a vertex property map
        vertex_property = {}
        # Add a data structure to enable efficient lookup of vertex by name
        vertex_lookup = {}
        # Data structure to track artifacts 
        artifacts = {}
        graph=RGL::DirectedAdjacencyGraph.new
        Dir.glob("#{Kudu.gitroot}/**/*.gemspec").each do |file|
          kudu_file = File.join(File.dirname(file),'kudu.yaml')
          next unless kudu = Kudu.parse_kudu_file(kudu_file)
          spec = Gem::Specification::load(file)
          raise Kudu::InvalidGemfile, "Failed to parse gemspec #{file}" if spec.nil?
          deps = kudu[:dependencies]
          # Publications do not store version (latest is the only relevent version)
          artifact = kudu[:publication].select {|k| k != :version}
          vertex_property[artifact] ||= {} 
          vertex_property[artifact][:gemspec] = file
          vertex_property[artifact][:version] = kudu[:publication][:version]
          # Fail if duplicate projects are detected
          raise Kudu::DuplicateProjectFound, "Duplicate gem name detected #{spec.name}" unless artifacts[spec.name].nil?
          graph.add_vertex(artifact)
          name = full_name(artifact)
          artifacts[name] = artifact
          vertex_lookup[name] = artifact
          deps.each do |dep|
            validate(dep)
            fullname = full_name(dep)
            vertex_lookup[fullname] = dep
            graph.add_edge(artifact, dep)
            vertex_property[dep] ||= {}
            vertex_property[dep][:version] = dep[:version] unless dep[:version].nil?
           end
        end
        return graph, vertex_lookup, vertex_property
      end
      
      def validate dep
        if dep[:group] == 'in-house' && !dep[:version].nil?
          raise Kudu::VersionSpecifiedForInHouse, "Dependencies with group in-house should not specify a version #{dep[:namespace]} #{dep[:name]}" 
        end
      end

      def verbose
        @verbose ||= false
      end

      def verbose= value
        @verbose = value
      end

      def full_name artifact
        Kudu.with_logging(self, __method__) do
          fullname = artifact[:namespace] ? artifact[:namespace] + "_" + artifact[:name] : artifact[:name]
        end
      end

      def build_order
        Kudu.with_logging(self, __method__) do
          self.graph.topsort_iterator.to_a.reverse.select{ |a| a[:group] == 'in-house'}
        end
      end
      
      def vertex_from_name(name)
        Kudu.with_logging(self, __method__) do
          return name if name.kind_of?(Hash)
          self.vertex_lookup[name]
        end
      end

      def all(vertex, transitive=true)      
        in_house(vertex, transitive) + third_party(vertex, transitive)
      end

      def in_house(vertex, transitive=true)
        Kudu.with_logging(self, __method__) { dependencies(vertex,'in-house', transitive) }
      end
      
      def third_party(vertex, transitive=true)
        Kudu.with_logging(self, __method__) { dependencies(vertex, 'third-party', transitive) }
      end

      def dependencies(vertex, group, transitive)
        Kudu.with_logging(self, __method__) do
          v = vertex_from_name(vertex)
          if transitive
            self.graph.dfs_iterator(v).to_a.reverse.select{ |a| a[:group] == group}
          else
            self.graph.adjacent_vertices(v).select { |a| a[:group] == group }
          end
        end
      end

      def gemspec(vertex)
        Kudu.with_logging(self, __method__) do
          v = vertex_from_name(vertex)
          @vertex_property[v][:gemspec]
        end
      end

      def version(vertex)
        Kudu.with_logging(self, __method__) do
          v = vertex_from_name(vertex)
          @vertex_property[v][:version]
        end
      end
      
      def graph
        Kudu.with_logging(self, __method__) do
          @graph, @vertex_lookup, @vertex_property = initialize_graph if @graph.nil?
          @graph
        end
      end
      
      def vertex_lookup
        Kudu.with_logging(self, __method__) do
          @graph, @vertex_lookup, @vertex_property = initialize_graph if @graph.nil?
          @vertex_lookup
        end
      end

      def vertex_property(vertex)
        Kudu.with_logging(self, __method__) do
          @graph, @vertex_lookup, @vertex_property = initialize_graph if @graph.nil?
          @vertex_property[vertex] 
        end
      end

    end
  end

end
