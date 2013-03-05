#!/usr/bin/env ruby

raise 'Must run as root' unless Process.uid == 0
kitchen = File.expand_path(File.join(File.dirname(__FILE__), '..', 'kitchen'))
Dir.chdir(kitchen)
cmd = "chef-solo -c solo.rb -j flex.json"
puts cmd
puts `#{cmd}`

    