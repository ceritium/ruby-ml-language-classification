require "twitter"
require "dotenv/load"

require "./languages"

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV["CONSUMER_KEY"]
  config.consumer_secret     = ENV["CONSUMER_SECRET"]
end

tweets_max = (ENV["TWEETS_MAX"] || 100).to_i

Languages::LIST.each do |lang|
  File.open("data/#{lang}.txt", "w") do |f|
    puts "Fetching #{lang}..."
    client.search("*", lang: lang).take(tweets_max).map(&:text).each do |text|
      f.write text.delete("\n")
      f.write "\n"
    end
  end
end
