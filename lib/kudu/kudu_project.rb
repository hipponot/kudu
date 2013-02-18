require_relative 'error'

module Kudu

  class KuduProject

    KNOWN_TYPES = ['ruby']

    attr_reader :type
    attr_reader :path

    def initialize(kudu_spec)
      begin
        @spec = YAML::load(IO.read(kudu_spec))
        if not @spec[:publication].is_a?(Hash)
          raise Kudu::InvalidKuduSpec, "#{kudu_spec} missing publication: Hash"
        elsif !@spec[:dependencies].is_a?(Array)
          raise Kudu::InvalidKuduSpec, "Kudufile #{kudu_spec} missing dependencies: Array"
        end
      rescue
        raise Kudu::InvalidKuduSpec, "Failed to parse #{kudu_spec} as YAML" 
      end
      @type = @spec[:publication][:type].nil? ? "Undefined" : @spec[:publication][:type]
      @path = File.basename(kudu_spec)
    end

    class << self

      def project(project_name)
        project_name ||= File.exist?('kudu.yaml') ? File.basename(Dir.pwd) : nil
        unless project_name
          Kudu.ui.error "Can't find project #{project_name}"
          raise ProjectNotFound
        end
        projects[project_name]
      end

      def projects
        @@projects ||= initialize_projects
      end

      def initialize_projects
        p = {}
        Dir.glob("#{Kudu.gitroot}/**/kudu.yaml").each do |file|
          p[File.basename(File.dirname(file))] = KuduProject.new(file)
        end
        p
      end

    end

  end 
end 




