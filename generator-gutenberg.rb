require 'classifier-reborn'
require 'charlock_holmes'
require "pry"
require "thor"

class TextGeneratorCli < Thor
  desc "hello NAME", "say hello to NAME"

  option :deep, default: 4
  option :words, default: 50
  option :language, default: "es"
  option :books, default: 5

  def generate
    tg = TextGenerator.new(options)
    tg.print_info
    tg.index_books
    tg.generate
  end
end

class TextGenerator

  attr :options, :hash 

  def initialize(options = {})
    @options = options
    @hash = {}
  end

  def print_info
    puts "Generate text with options:"
    puts "Deep: #{@options[:deep]}"
    puts "Words: #{@options[:words]}"
    puts "Language: #{@options[:language]}"
    puts "Books source: #{@options[:books]}"
  end

  def generate
    puts 
    puts "= Calculating seed words..."
    word_keys = hash.select{|k,v| k.length > 5 }.sort_by {|_key, value| -value.count}.to_h.keys

    wow = []
    while wow.flatten.count < options[:words]
      if wow.count == 0
        wow = fetch_word(seed(word_keys))
      end
      wow = fetch_word(wow)
    end
  end

  def fetch_word(text = [])
    puts "\e[H\e[2J"
    puts text.flatten.join(" ")

    continue = true
    to_return = nil

    options[:deep].downto(2).each do |time|
      if continue
        string = text.flatten.reverse[0..time].reverse.join(" ")
        string_hash = hash[string]
        if string_hash && string_hash.keys.count > 1
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
  end

  def deeper(arr = [])
    arr2 = [arr[0]]
    arr[1..-1].each do |item|
      arr2 = [arr2, item]
    end

    arr2
  end

  def seed(keys)
    deeper(keys.shuffle.first.split(" "))
  end

  def index_books
    puts
    puts "= Indexing..."
    Dir["gutenberg/#{options[:language]}/*.txt"].shuffle.each_with_index do |path, book_index|
      break if book_index >= (@options[:books].to_i)
      puts "- #{book_index + 1} #{path}"

      content = File.open(path).read
      detection = CharlockHolmes::EncodingDetector.detect(content)
      utf8_content = CharlockHolmes::Converter.convert(content,
                                                      detection[:encoding],
                                                      'UTF-8')

      arr = utf8_content.split(" ")
      arr.each_with_index do |word, index|
      index_word(word, arr[index+1])
        options[:deep].times do |time|
          words = time.downto(1).map{|i| arr[index - i]}
          words << word
          text = words.join(" ")
          index_word(text, arr[index+1])
        end
      end
    end
  end

  def index_word(word1 = nil, word2 = nil)
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
end

TextGeneratorCli.start(ARGV)
