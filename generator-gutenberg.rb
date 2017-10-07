require 'classifier-reborn'
require 'charlock_holmes'
require "pp"
require "pry"

hash = {}

deep = 3

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
  break if i_f >= 15

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
#

times = 0

deeper = -> (arr) {
  arr2 = [arr[0]]
  arr[1..-1].each do |item|
    arr2 = [arr2, item]
  end

  arr2
}


fetch_word = -> (text = []) {
  puts "\e[H\e[2J"
  pp text.flatten.join(" ")
  # sleep 0.05


  continue = true
  to_return = nil

  deep.downto(2).each do |time|
    if continue
      string = text.flatten.reverse[0..time].reverse.join(" ")
      string_hash = hash[string]
      if string_hash && string_hash.keys.count > 1
        # binding.pry
        # new_word = string_hash.sort_by {|_key, value| -value}[0..5].to_h.keys.shuffle.first
        new_word = string_hash.sort_by {|_key, value| -value}.map{|xv| xv[-1].times.map{|x| xv[0]}}.flatten.shuffle.first
        to_return = [text, new_word]
        hash[string].delete(new_word)
        continue = false
      end
    end
  end

  if to_return.nil?
    if text.flatten.count > 1
      to_return = text[0]
    else
      to_return = []
    end
  end
  to_return
}


puts "preparing"
word_keys = hash.select{|k,v| k.length > 5 }.sort_by {|_key, value| -value.count}.to_h.keys

seed = -> (word_keys){
  deeper.call(word_keys.shuffle.first.split(" "))
}

puts "generating"
start_with = nil
wow = start_with || [] || deeper.call("veronica canta".split(" "))
while wow.flatten.count < 50
  if wow.count == 0
    wow = start_with || fetch_word.call(seed.call(word_keys))
  end
  wow = fetch_word.call(wow)
end
