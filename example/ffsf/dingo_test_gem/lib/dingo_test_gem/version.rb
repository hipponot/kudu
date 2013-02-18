require 'yaml'
module Kudu
module TestGem
  kudu = YAML::load(IO.read(File.join(File.dirname(__FILE__), '../../kudu.yaml')))
  VERSION = kudu[:publication][:version]
  NAME = kudu[:publication][:name]
end
end
