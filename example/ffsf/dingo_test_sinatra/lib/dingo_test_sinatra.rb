require "sinatra/base"
require "json"
require "kudu_test_sinatra/version"
require "kudu_test_gem"
module Kudu
  module TestSinatra 
    class Service < Sinatra::Base
      get '/' do
        "Hello from TestSinatra & " + Kudu::TestGem.hello()
      end
      get '/hello' do
        cache_control :max_age => 0
        puts "#{Time.now} Kudu: Hello!"
        status 200
        body JSON.pretty_generate({
          "status" => "success",
          "service" => "TestSinatra"
        })
      end
    end
  end
end
