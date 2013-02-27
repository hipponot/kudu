module Kudo

  class << self
    def gitroot
      `git rev-parse --show-toplevel`.chomp
    end
  end

end