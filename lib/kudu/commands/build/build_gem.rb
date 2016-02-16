require_relative 'gem_builder'

module Kudu
  class BuildGem

    def initialize(options, project)
      builder = GemBuilder.new(options, project)
      builder.build_gem unless options[:only_third_party]
      builder.install_third_party unless options[:skip_third_party]
    end

  end
end
