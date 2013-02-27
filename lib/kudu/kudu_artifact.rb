require_relative 'error'
  require_relative 'kudu_artifact'

  module Kudu

    class KuduArtifact

      attr_reader :name
      attr_reader :version
      attr_reader :type
      attr_reader :group


      def initialize(name, version, type, group)
        @name = name
        @version = version
        @type = type
        @group = group
      end

      def to_hash
        {:name=>@name, :version=>@version, :type=>@type, :group=>@group}
      end

      class << self
        def new_from_hash(hash)
          self.new(hash[:name], hash[:version].nil? ? 'latest' : hash[:version], hash[:type], hash[:group])
        end
      end
    
    end

  end