require "sinatra/base"
require "json"
require "kudu_example_sinatra/version"
module Kudu
  module ExampleSinatra 
    class Service < Sinatra::Base
      get '/' do
        "Hello World"
      end
      get '/hello' do
        cache_control :max_age => 0
        puts "#{Time.now} Kudu: Hello!"
        status 200
        body JSON.pretty_generate({
          "status" => "success",
          "service" => "ExampleSinatra"
        })
      end
    end
  end
end