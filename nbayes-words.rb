require "nbayes"
require "pp"
require "./languages"

nbayes = NBayes::Base.new

test = {}

Languages::LIST.each do |lang|
  lines = File.open("data/#{lang}.txt").each_line.to_a
  count = lines.count

  lines[0..count/2].each do |line|
    nbayes.train(line.split(/\s+/), lang)
    test[lang] = lines[count/2+1..-1]
  end
end


results = {}
Languages::LIST.each do |lang|
  result_lang = {}
  result_lang = {total: test[lang].count, success: 0}
  test[lang].each do |line|
    tokens = line.split(/\s+/)
    result = nbayes.classify(tokens)
    if result.max_class == lang
      result_lang[:success] += 1
    end
  end

  result_lang[:percent] = (result_lang[:success].to_f / result_lang[:total])*100
  results[lang] = result_lang
end


puts "TESTS"
pp results

if ARGV[0]
  tokens = ARGV[0].split(/\s+/)
  result = nbayes.classify(tokens)
  puts
  puts "LANG: #{result.max_class}"
  puts
  pp result
end
