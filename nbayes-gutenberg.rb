require "nbayes"
require "pp"
require "pry"

require 'charlock_holmes'

nbayes = NBayes::Base.new

['es', 'en', 'fr'].each do |lang|
  Dir["gutenberg/#{lang}/*"].each_with_index do |path, index|
    puts "#{index}, #{path}"
    break if index > 10

    if File.file?(path)
      content = File.open(path, "r:ISO-8859-1").read
      detection = CharlockHolmes::EncodingDetector.detect(content)
      utf8_content = CharlockHolmes::Converter.convert(content,
                                                      detection[:encoding],
                                                      'UTF-8')

      nbayes.train(utf8_content.split(/\s+/), lang)
    end
  end
end

if ARGV[0]
  tokens = ARGV[0].split(/\s+/)
  result = nbayes.classify(tokens)
  puts
  puts "LANG: #{result.max_class}"
  puts
  pp result
end
