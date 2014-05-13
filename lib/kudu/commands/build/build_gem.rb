require_relative 'gem_builder'

module Kudu
  class BuildGem

    def initialize(options, project)
      builder = GemBuilder.new(options, project)
      builder.update_version if options[:production]
      builder.build_gem
      builder.install_third_party unless options[:'skip-third-party']
    end

  end
end
