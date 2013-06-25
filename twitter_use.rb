require 'twitter'

Twitter.configure do |config|
  config.consumer_key = ENV['YOUR_CONSUMER_KEY']
  config.consumer_secret = ENV['YOUR_CONSUMER_SECRET']
  config.oauth_token = ENV['YOUR_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['YOUR_OAUTH_TOKEN_SECRET']
end

class Dates

  def self.week_dates
    i = 0
    @@dates = []
    while i < 8
      
      @@dates <<(Time.now - i*86400).strftime("%Y-%m-%d")
      i += 1
    end
    #@dates.reverse! first item in array is the lowest date
    @@dates
  end

end

class Tweeter
  attr_accessor :total_tweets, :handle, :dates

  @@end_date = '2013-06-24' #delete for later?
  @@start_date = '2012-06-03' #will populate later (Time.now-86400).strftime("%Y-%m-%d")
  @@Tweeters = []
  @@Points = []
  @tweet_point = 1
   #will use to calculate consecutiveness

# Create an array of dates included in queries which will be crossed against the tweet_counter loop
# to count tweest on a per-day basis
  def week_dates
    i = 0
    @dates = []
    while i < 8
      @dates <<(Time.now - i*86400).strftime("%Y-%m-%d")
      i += 1
    end
    #@dates.reverse! first item in array is the lowest date
    @dates
  end

  def initialize(handle)
    @handle = handle
    @total_tweets = 0 #total number of tweets pulled for a handle using API
    @@Tweeters << @handle
  end

  #count tweets -- FINISHED
  def tweet_counter(handle)
    Dates.week_dates
    i = 0
    @tweets = []
    @tweets_per_day = [] #array contains number of tweets for each day of the week by index 0 being today and 6 being start of the week
    @total_tweets = 0
    until i > (Dates.week_dates.length-2) #until the last item in array, which we need to pull today's tweet
      @tweets << Twitter.search("from:#{handle}", :count => 15, :until => Dates.week_dates[i], :since => Dates.week_dates[i+1]).results.map do |status|
        "#{status.from_user}/ #{status.text} / #{Dates.week_dates[i]}" #if need to test, push this into array and puts it later
        # sleep(1)
      end
      @tweets_per_day.push(@tweets[i].length) #storing on a given day how many tweets were tweeted
      @total_tweets += @tweets[i].length
      i +=1
    end
      @total_tweets

  end

  def self.tweeter_points
    @@Points = @@Tweeters.map do |tweeter|
      tweet_counter(tweeter)*@tweet_point
    end
  end

  

end

shannon = Tweeter.new('s_byrne')
shannon.tweet_counter('s_byrne')

# youssif.week_dates