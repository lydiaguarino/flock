require 'twitter'

Twitter.configure do |config|
  config.consumer_key = ENV['YOUR_CONSUMER_KEY']
  config.consumer_secret = ENV['YOUR_CONSUMER_SECRET']
  config.oauth_token = ENV['YOUR_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['YOUR_OAUTH_TOKEN_SECRET']
end

class Tweeter
  attr_accessor :total_tweets, :handle

  @@end_date = '2013-06-24' #must be formatted as YYYY-MM-DD
  @@start_date = '2012-06-03' #will populate later (Time.now-86400).strftime("%Y-%m-%d")
  @@Tweeters = []
  @@Points = []
  @tweet_point = 1

  def week_dates
    i = 0
    @dates = []
    while i < 8
      @dates <<(Time.now - i*86400).strftime("%Y-%m-%d")
      i += 1
    end
    @dates.reverse! #first item in array is the lowest date
  end

  def initialize(handle)
    @handle = handle
    @total_tweets = 0 #total number of tweets pulled for a handle using API
    @@Tweeters << @handle
  end

  #count tweets
  def tweet_counter(handle)
    week_dates
    i = 0
    until i < (@dates.length-1) #until the last item in array, which we need to pull today's tweet
      tweets = Twitter.search("from:#{handle}", :count => 20000, :until => @dates[i+1], :since => @dates[i]).results.map do |status|
        "#{status.from_user} / #{status.text} / #{@dates[]}"
        i +=1
      end
      tweets.count
      puts tweets.count
      puts tweets
    end
  end

  def self.tweeter_points
    @@Points = @@Tweeters.map do |tweeter|
      tweet_counter(tweeter)*@tweet_point
    end
  end

  

end

youssif = Tweeter.new('s_byrne')
youssif.tweet_counter('s_byrne')
youssif.week_dates