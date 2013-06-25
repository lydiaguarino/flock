require 'twitter'

Twitter.configure do |config|
  config.consumer_key = ENV['YOUR_CONSUMER_KEY']
  config.consumer_secret = ENV['YOUR_CONSUMER_SECRET']
  config.oauth_token = ENV['YOUR_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['YOUR_OAUTH_TOKEN_SECRET']
end

class Dates
  
  # Create an array of dates included in queries which will be crossed against the tweet_counter loop
  # to count tweest on a per-day basis

  def self.week_dates
    i = 0
    @@dates = []
    while i < 8
      @@dates <<(Time.now - i*86400).strftime("%Y-%m-%d")
      i += 1
    end
    @@dates
  end

end



class Tweeter
  attr_accessor :total_tweets

  @@tweeters = []
  @@points = []
  @tweet_point = 1

  def initialize
    @total_tweets = 0 #total number of tweets pulled for a handle using API
    @@tweeters << @handle
  end

  #count tweets -- FINISHED
  def tweet_counter(handle)
    Dates.week_dates
    i = 0
    @tweets = []
    @tweets_per_day = [] #array contains number of tweets for each day of the week by index 0 being today and 6 being start of the week
    @total_tweets = 0
    until i > (Dates.week_dates.length-2) #until the last item in array, which we need to pull today's tweet
      @tweets << Twitter.search("from:#{handle}", :count => 5, :until => Dates.week_dates[i], :since => Dates.week_dates[i+1]).results.map do |status|
        "#{status.from_user}/ #{status.text} / #{Dates.week_dates[i]}" #if need to test, push this into array and puts it later
      end
      @tweets_per_day << @tweets[i].length #storing on a given day how many tweets were tweeted to calculate consecutiveness
      @total_tweets += @tweets[i].length
      i +=1
    end
      puts @total_tweets
  end

  #calculate points for original tweets only
  def tweet_points
    @points_per_day = @tweets_per_day.map do |tweets|
      tweets*3.1
    end
    puts @points_per_day.inspect
  end

  def consec_points
    #example of array -> [0,1,2,3,1,4,0]
    #i = 0
    index = 0 
    i = 1
    @consec_modified = @points_per_day.map do |point|
      if index > 0
        if @points_per_day[index] > 0 && @points_per_day[index-1] > 0
          i+=0.5
        else
          i = 1
        end
      else 
        i = 1
      end
      index += 1
      point*i
    end
    puts @consec_modified.inspect
  end
end

shannon = Tweeter.new
shannon.tweet_counter('s_byrne')
shannon.tweet_points
shannon.consec_points

# youssif.week_dates