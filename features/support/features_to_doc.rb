#!/usr/bin/ruby

files = Dir.glob("*.feature").sort{|a,b| File.new(a).ctime <=> File.new(b).ctime}

header =<<EOF 
<html>
<style>
img{
  width: 320px;
  display: block;
  margin-top: 25px;
  border: solid 2px black;
}
li{
  font-size: 2em;
}
</style>
<body><pre>
EOF
footer = "</pre></body></html>"
table_of_contents = "<h1>Table of Contents</h1>"
output = ""

files.each{|file|
  STDERR.puts file
  raw_file = `cat #{file}`
  raw_file.gsub!(/(should look like )(.*\.jpg).*/){
    "#{$1}<img src='images/#{$2}'>"
  }
  raw_file.gsub!(/(Feature:.*)/){
    feature_name = $1
    id_name = feature_name.downcase.gsub(/ /){"_"}
    table_of_contents += "<li><a href='##{id_name}'>#{feature_name.gsub(/Feature: /,"")}</a></li>"
    "<hr/><h1 id='#{id_name}'>#{feature_name}</h1>"
    "<hr/><h1 id='#{id_name}'>#{feature_name}</h1>"
  }

  raw_file.gsub!(/(Scenario:.*)/){"<h3>#{$1}</h3>"}
  output += raw_file
}

puts header
puts table_of_contents
puts output
puts footer
