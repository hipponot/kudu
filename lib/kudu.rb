require_relative "kudu/bootstrap"
require_relative "kudu/ui"

module Kudu

  class << self
    Bootstrap.init($*)
    attr_writer :ui
    def ui
      @ui ||= UI.new
    end
  end

end

