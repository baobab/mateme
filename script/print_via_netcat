#!/usr/bin/ruby
if ARGV[1].nil?
  if ENV["DISPLAY"].nil?
    log = File.open("/tmp/print_log", "a")
    log.puts "No destination or DISPLAY set"
    exit
  end
  destination = ENV["DISPLAY"].split(":").first unless ENV["DISPLAY"].nil?
else
  destination = ARGV[1]
end

`cat #{ARGV[0]} | netcat -q 1 #{destination} 4242`