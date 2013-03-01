#!/usr/bin/env ruby
require 'rubygems'
require 'whois'

domain = "#{ARGV[0]}.com"
puts "checking availibilty for #{domain}"
c = Whois::Client.new
r = c.query(domain)
if (r.available?)
  puts (domain + " is AVAILABLE")
else
  puts(domain + " is NOT available")
end
