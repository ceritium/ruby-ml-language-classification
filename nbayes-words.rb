require "nbayes"
require "pp"
require "./languages"

nbayes = NBayes::Base.new

Languages::LIST.each do |lang|
  File.open("data/#{lang}.txt").each_line do |line|
    nbayes.train(line.split(/\s+/), lang)
  end
end

if ARGV[0]
  tokens = ARGV[0].split(/\s+/)
  result = nbayes.classify(tokens)
  puts "LANG: #{result.max_class}"
  puts
  pp result
end
