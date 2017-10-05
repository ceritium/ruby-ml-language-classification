require 'classifier-reborn'
require 'charlock_holmes'
require "pp"
require "pry"

hash = {}
store = -> (word1, word2) do
	if word1 && word2
		word1 = word1.downcase
		word2 = word2.downcase
		if word1
			if hash[word1] 
				if hash[word1][word2]
					hash[word1][word2] += 1
				else
					hash[word1][word2]	= 1
				end	
			else
				hash[word1] = {word2 => 1}
			end
		end
	end
end

Dir["gutenberg/es/*"].shuffle.each_with_index do |path, index|
  puts "#{index}, #{path}"
  break if index > 5

  if File.file?(path)
		content = File.open(path).read
		detection = CharlockHolmes::EncodingDetector.detect(content)
		utf8_content = CharlockHolmes::Converter.convert(content,
																										detection[:encoding],
																										'UTF-8')

		arr = utf8_content.split(" ")
		arr.each_with_index do |word, index|
			store.call(word, arr[index+1])
			store.call("#{arr[index-1]} #{word}", arr[index+1])
			store.call("#{arr[index-2]} #{arr[index-1]} #{word}", arr[index+1])
		end
  end
end

# File.open("gutember.yml", "w") do |f|
# 	f.write hash.to_yaml
# end
#
# hash = YAML.load_file("gutember.yml")
# binding.pry


text = ["la", "vida"]

# generate = -> (words) {
#   posi = hash[words.reverse[0..1].reverse.join(" ")] || hash[words.reverse[0]] 
# 	posi.sort_by {|_key, value| -value}[0..5].to_h.keys.shuffle.each do |word|
# 		words << word
# puts words
# 		lol = generate.call(words.reverse[0..2].reverse)
# 		puts lol
# 		lol
# 	end
# }
#
# generate.call(text)

fetch_word = -> (index) {

	op3 = hash[text.reverse[0..2].reverse.join(" ")]
	op2 = hash[text.reverse[0..1].reverse.join(" ")]
	op1 = hash[text.reverse[0]]

	posi = if op3 && op3.keys.count > 2
		op3
	elsif op2 && op2.keys.count > 2
		op2
	else
		op1
	end

	lol = posi.sort_by {|_key, value| -value}[0..5].to_h.keys.shuffle.first
	lol
}

100.times do |time|
	text << fetch_word.call(time)

	puts "\e[H\e[2J"
	printf "%s", "\r#{text.join(" ")}\n"
	sleep 0.05
end



# if ARGV[0]
#   tokens = ARGV[0].split(/\s+/)
#   result = nbayes.classify(tokens)
#   puts
#   puts "LANG: #{result.max_class}"
#   puts
#   pp result
# end
