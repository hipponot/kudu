#!/usr/bin/env ruby

kitchen = File.expand_path(File.join(File.dirname(__FILE__), '..', 'kitchen'))
Dir.chdir(kitchen)
cmd = "sudo chef-solo -c solo.rb -j flex.json"
puts cmd
puts `#{cmd}`

    