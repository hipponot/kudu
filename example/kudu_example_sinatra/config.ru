$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require "kudu_example_sinatra"
run Kudu::ExampleSinatra::Service