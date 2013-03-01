require 'rvm'
require 'etc'
require 'rubygems/builder'
require 'rubygems/installer'

require 'ruby-prof' unless RUBY_PLATFORM=='java'

require_relative '../../error'
require_relative '../../util'
require_relative '../../rvm_util'
require_relative '../../dependency_graph'
require_relative '../../ui'
require_relative '../../kudu_project'

module Kudu

  class BuildSinatra
    
    include GemBuilder
    
  end

end
