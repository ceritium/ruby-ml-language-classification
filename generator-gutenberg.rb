require 'classifier-reborn'
require 'charlock_holmes'
require "pp"
require "pry"

hash = {}

deep = 4

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

Dir["gutenberg/es/*"].shuffle.each_with_index do |path, i_f|
  puts "#{i_f}, #{path}"
  break if i_f >= 5

  if File.file?(path)
		content = File.open(path).read
		detection = CharlockHolmes::EncodingDetector.detect(content)
		utf8_content = CharlockHolmes::Converter.convert(content,
																										detection[:encoding],
																										'UTF-8')

		arr = utf8_content.split(" ")
		arr.each_with_index do |word, index|
			store.call(word, arr[index+1])
      deep.times do |time|
        words = time.downto(1).map{|i| arr[index - i]}
        words << word
        text = words.join(" ")
        store.call(text, arr[index+1])
      end
		end
  end
end

puts "generating"

ops = {
	1 =>  0,
	2 =>  0,
	3 =>  0,
	4 =>  0
}

max = 40
times = 0

fetch_word = -> (text = [], key = nil, value = nil) {
  if text.length == 0
    word_keys = hash.select{|k,v| k.length > 5 }.sort_by {|_key, value| -value.count}.to_h.keys
    text = word_keys.shuffle.first.split(" ")
  end

  puts "\e[H\e[2J"
  printf "%s", "\r#{text.join(" ")}\n"
  sleep 0.05

  deep.downto(1).each do |time|
    string = text.reverse[0..time].reverse.join(" ")
    string_hash = hash[string]
    # if string_hash && (time == 1 || string_hash.keys.count > 2)
    if string_hash && (time == 0 || string_hash.keys.count > 1)
      # ops[time+1] += 1

      word = string_hash.sort_by {|_key, value| -value}[0..5].to_h.keys.shuffle.first
      text << word

      times +=1 
      fetch_word.call(text, string, word) #if times < max
      break;
    # elsif time == 1
    #   times -= 1
    #   if key && value
    #     hash[key].delete(value)
    #   end
    #   fetch_word.call(text[0..-2])
    # end
    end
  end

    times -= 1
    if key && value
      hash[key].delete(value)
    end
    fetch_word.call(text[0..-2])
}

# text = "trajes de paño blanco".split(" ")
fetch_word.call()

  # puts "\e[H\e[2J"
  # printf "%s", "\r#{text.join(" ")}\n"
  # sleep 0.05
# puts text.join(" ")

pp ops
