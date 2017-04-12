require 'rexml/document'
require 'rexml/xpath'
require 'resolv'
require 'public_suffix'

set = Set.new

open("#{__dir__}/block.txt").each_line do |it|
  set << it.chomp
end

Dir["#{__dir__}/../https-everywhere/rules/*.xml"].each do |rule|
  next if rule =~ /branded/
  next if rule =~ /[*]/
  #$stderr.print '.'
  $stderr.flush
  doc = REXML::Document.new(File.open(rule))
  REXML::XPath.each(doc, "//target") do |el|
    host = el.attributes["host"]
    if set.include? PublicSuffix.domain(host)
      $stderr.puts "blocked #{host}"
      next
    end
    puts "https://#{host}/" unless host =~ /[*]/
  end
  $stdout.flush
end
