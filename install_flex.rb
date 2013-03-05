#!/usr/bin/env ruby

raise 'Must run as root' unless Process.uid == 0
Dir.chdir('kitchen')
cmd = "chef-solo -c solo.rb -j flex.json"
puts cmd
puts `#{cmd}`

    