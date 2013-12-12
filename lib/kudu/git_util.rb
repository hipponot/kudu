module Kudu

  class << self

    def gitroot
      `git rev-parse --show-toplevel`.chomp
    end

    def git_commit_count
      `git log --pretty=format:'' | wc -l`.chomp.gsub(/\s+/, "")
    end

  end

end
