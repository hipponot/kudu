require_relative 'gem_builder'

module Kudu
  class BuildGem

    def initialize(options, project)
      GemBuilder.new(options, project)
    end

  end
end
