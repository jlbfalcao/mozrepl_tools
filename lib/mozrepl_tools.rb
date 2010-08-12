
pwd = File.dirname(__FILE__)

puts "ruby '#{pwd}/textmate/Support/lib/mozrepl_tools.rb' #{ARGV[0]}"
system("ruby '#{pwd}/textmate/Support/lib/mozrepl_tools.rb' #{ARGV[0]}")