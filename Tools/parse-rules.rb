require 'rexml/document'
require 'rexml/xpath'
require 'resolv'
require 'public_suffix'

set = Set.new

open("#{__dir__}/block.txt").each_line do |it|
  set << it.chomp
end

rank = {}
open("#{__dir__}/Quantcast-Top-Million.txt").each_line do |it|
  next unless it =~ /^\d/
  rank[it.split(/\s+/).last] = it.split(/\s+/).first.to_i
end

domains = []

# Holder for domain and rank, calculates an estimated traffic score
class Domain
  attr_accessor :host, :rank
  def initialize(host, rank)
    @host = host
    @rank = rank
  end

  def traffic
    prediction = Math.exp(20.0599465 + -0.7699931 * Math.log(rank.to_f))
    prediction /= 2 if ["google.com", "youtube.com"].include? @host
    prediction
  end
end

done = Set.new
Dir["#{__dir__}/../https-everywhere/rules/*.xml"].each do |rule|
  next if rule =~ /branded/
  next if rule =~ /[*]/
  doc = REXML::Document.new(File.open(rule))
  REXML::XPath.each(doc, '//target') do |el|
    host = el.attributes['host']
    next if host =~ /[*]/
    main = PublicSuffix.domain(host)
    if set.include? main
      $stderr.puts "blocked #{host}"
      next
    end

    if !rank[main].nil? && !done.include?(main)
      domains << Domain.new(main, rank[main].to_i)
      done << main
    else
      $stderr.puts "skipping #{host}"
    end
  end
end

total = domains.map(&:traffic).reduce(&:+).to_f
$stderr.puts "traffic: #{total}, domains: #{domains.length}"

# create a cdf
cum = 0.to_f
domains.sort_by { |d| -d.traffic }.each do |d|
  cum += d.traffic / total
  $stdout.puts "#{cum}\t#{d.host}"
end
