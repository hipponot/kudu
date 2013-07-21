require 'yaml'
require_relative 'error'
require_relative 'kudu_artifact'

module Kudu

  class KuduProject

    KNOWN_PROJECT_TYPES = ['gem', 'sinatra']
    KNOWN_ARTIFACT_TYPES = ['gem']

    attr_reader :name
    attr_reader :version
    attr_reader :type
    attr_reader :group
    attr_reader :publications
    attr_reader :directory

    def initialize(kudu_spec)
      @spec = KuduProject.load_and_validate_spec(kudu_spec)
      @name = @spec[:project][:name]
      @type = @spec[:project][:type]
      @directory = File.dirname(kudu_spec)
      @publications = []
      @spec[:publications].each do |pub|
        @publications << KuduArtifact.new_from_hash(pub)
      end
      @dependencies = []
      @spec[:dependencies].each do |dep|
        @dependencies << KuduArtifact.new_from_hash(dep)
      end
      @version = @publications[0].version
    end

    def dependencies group=nil
      if group.nil?
        @dependencies
      else
        @dependencies.select { |d| d.group == group }
      end
    end

    class << self

      def load_and_validate_spec(kudu_spec)
        spec = {}
          #exists
          unless File.exist?(kudu_spec)
            raise Kudu::InvalidKuduSpec, "Can't open #{kudu_spec}"   
          end
          # valid YAML
          begin
            spec = YAML::load(IO.read(kudu_spec))
          rescue SyntaxError
            raise Kudu::InvalidKuduSpec, "Failed to parse #{kudu_spec} as YAML" 
          end
          # Project hash exists and is non empty
          raise Kudu::InvalidKuduSpec, "#{kudu_spec} project must be a non-empty hash" unless spec[:project].is_a?(Hash)  
          raise Kudu::InvalidKuduSpec, "#{kudu_spec} project must be a non-empty hash" if spec[:project].empty?
          # Project name is a non-empty string
          raise Kudu::InvalidKuduSpec, "#{kudu_spec} project name must be a non emtpy string" unless spec[:project][:name].is_a?(String) 
          raise Kudu::InvalidKuduSpec, "#{kudu_spec} project name must be a non emtpy string" if spec[:project][:name].empty?
          # Project type is a non-empty string and is known
          if not spec[:project][:type].is_a?(String) || KNOWN_PROJECT_TYPES.include?(spec[:project][:type])
            raise Kudu::InvalidKuduSpec, "#{kudu_spec} project type must be one of #{KNOWN_PROJECT_TYPES.inspect}"
          end          
          # publications is non-emtpy array
          raise Kudu::InvalidKuduSpec, "#{kudu_spec} publications must be a non-emtpy array" unless spec[:publications].is_a?(Array) 
          raise Kudu::InvalidKuduSpec, "#{kudu_spec} publications must be a non-emtpy array" if spec[:publications].empty?
          # dependencies is array (empty okay)
          raise Kudu::InvalidKuduSpec, "#{kudu_spec} dependencies must be an array" unless spec[:dependencies].is_a?(Array) 
          spec
        end
        
        
        def project(project_name)
          # allows for skipping the project name parameter when commands are issued from project root directory
          project_name ||= File.exist?('kudu.yaml') ? KuduProject.new('kudu.yaml').name : nil
          unless project_name && projects.include?(project_name)
            Kudu.ui.error "Can't find project #{project_name}: Use the -n option or run from directory that contains a kudu.yaml"
            raise ProjectNotFound
          end
          projects[project_name]
        end

        def projects
          @@projects ||= initialize_projects
        end

        private

        def initialize_projects
          p = {}
          Dir.glob("#{Kudu.gitroot}/**/kudu.yaml").each do |file|
            spec = KuduProject.new(file)
            raise DuplicateProjectFound, "Detected duplicate projects #{spec.directory} collides with #{p[spec.name].directory}" if p.has_key?(spec.name)
            p[spec.name] = spec
          end
          p.each do |name, spec|
            spec.dependencies.each do |d|
              if d.group == 'in-house' && d.version != 'latest'
                raise KudoSpecInHouseVersion, "Invalid spec: #{kudu_spec}, versioning of in-house dependencies is not supported, #{d.inspect}"
              end  
            end
          end
          p
        end
        
      end # class << self

    end 
  end 




