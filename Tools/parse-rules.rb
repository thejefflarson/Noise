require 'csv'
require 'public_suffix'
require 'rexml/document'
require 'rexml/xpath'
require 'resolv'

set = Set.new

open("#{__dir__}/block.txt").each_line do |it|
  set << it.chomp
end

rank = {}
CSV.foreach("#{__dir__}/majestic_million.csv", headers: true) do |row|
  rank[row['Domain']] = row['RefSubNets'].to_i
end

domains = []

# Holder for domain and rank, calculates an estimated traffic score
Domain = Struct.new(:host, :traffic)

done = Set.new
Dir["#{__dir__}/../https-everywhere/rules/*.xml"].each do |rule|
  next if rule =~ /branded/
  next if rule =~ /[*]/
  doc = REXML::Document.new(File.open(rule))
  REXML::XPath.each(doc, '//target') do |el|
    host = el.attributes['host']
    next if host =~ /[*]/
    main = PublicSuffix.domain(host)
    if set.include?(main) || set.include?(host)
      $stderr.puts "blocked #{host}"
      next
    end

    if !rank[host].nil? && !done.include?(host)
      domains << Domain.new(host, rank[host].to_i)
      done << host
    else
      $stderr.puts "skipping #{host}"
    end
  end
end

total = domains.map(&:traffic).reduce(&:+).to_f
$stderr.puts "traffic: #{total}, domains: #{domains.length}"

# create a cdf
accum = 0.to_f
domains.sort_by { |d| -d.traffic }.each do |d|
  accum += d.traffic / total
  $stdout.puts "#{accum}\thttps://#{d.host}/"
end
