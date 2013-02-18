require "bundler/setup"
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require "kudu_test_gem"
run Kudu::TestGem::Service
