require 'twitter'
require 'gmail'

Twitter.configure do |config|
  config.consumer_key = ENV['YOUR_CONSUMER_KEY']
  config.consumer_secret = ENV['YOUR_CONSUMER_SECRET']
  config.oauth_token = ENV['YOUR_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['YOUR_OAUTH_TOKEN_SECRET']
end

class Email
  @@username = ENV['GMAILUSER']
  @@password = ENV['GMAILPSWD']

  def self.send(emails)
    @flock = Flock.new(["sagarispatel","s_byrne","techpeace","makersquare","youssifwashere","lydiaguarino"])
    @email_body = @flock.email_format

    gmail = Gmail.connect(@@username, @@password)
      emails.each do |email|
        gmail.deliver do
          to email
          subject "Your Weekly Mother Flockerboard"
          text_part do
            body @email_body #this is breaking us!!!!!!! AHHHHH!!!!
          end
          html_part do
            content_type 'text/html; charset=UTF-8'
            # body @
          end
          # add_file "/path/to/some_image.jpg"
        end
      end
    gmail.logout
  end
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
        "#{status.id}"
      end
      @tweets_per_day << @tweets[i].length #storing on a given day how many tweets were tweeted to calculate consecutiveness
      @total_tweets += @tweets[i].length
      i +=1
    end
      @total_tweets 
  end

  #mentions
  def mention_counter(handle)
    @mentions = Twitter.search("to:#{handle}", :count => 200, :until => Dates.week_dates[0], :since => Dates.week_dates[6]).results.count
  end

  #retweet counter to assign points
  def retweet_count(handle)
    @retweet_total = 0
    Twitter.search("from:#{handle} -rt", :count => 2000, :until => Dates.week_dates[0], :since => Dates.week_dates[6]).results.map do |status|
       @retweet_total += status.retweet_count
    end
    @retweet_total
  end

  #use to pass through points method so we don't have to call all the methods
  def counter(handle)
    tweet_counter(handle)
    mention_counter(handle)
    retweet_count(handle)
  end

  #calculate points for original tweets only
  def tweet_points
    @tweet_points = 0
    @points_per_day = @tweets_per_day.map do |tweets|
      tweets
    end
    @points_per_day.each do |points|
      @tweet_points += points
    end
  end

  def mention_points
    @mention_points = @mentions * 2
    @mention_points
  end

  def retweet_points
    @retweet_points = @retweet_total* 2
    @retweet_points
  end

  #takes handle as argument to just run all the counter methods to get points
  def total_points(handle)
    counter(handle)
    tweet_points
    consec_points
    mention_points
    retweet_points
    @total_points = @retweet_points + @mention_points + @consec_points
    @tweeter_hash = {}
    @tweeter_hash[:handle] = handle
    @tweeter_hash[:total_points] = @total_points
    @tweeter_hash[:tweet_points] = @tweet_points
    @tweeter_hash[:consec_points] = @consec_points
    @tweeter_hash[:mention_points] = @mention_points
    @tweeter_hash[:retweet_points] = @retweet_points
    @tweeter_hash
  end

  # def follower_points

  # end

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
    @consec_points = 0
    @consec_modified.each do |point|
      @consec_points += point
    end
    @consec_points
  end

end

class Flock
  def initialize(array)
    @array = array
  end

  def user_gen
    @flock_array = []
    @array.each do |handle|
      @flock_array << Tweeter.new.total_points(handle)
    end
    @flock_array.sort_by! {|tweeter| tweeter[:total_points]}.reverse!
    @flock_array
  end

  def email_format
      user_gen
      puts "The Mother Flocker Weekly Leaderboard"
      puts ""
      puts "@#{@flock_array.first[:handle]} is the Mother Flocker of the week!"
      puts ""
    @flock_array.each do |tweeter|
      puts "@#{tweeter[:handle]} | TOTAL POINTS: #{tweeter[:total_points]} | TOTAL RETWEETS: #{tweeter[:retweet_points]/2} | TOTAL MENTIONS: #{tweeter[:mention_points]/2} | TOTAL TWEETS: #{tweeter[:tweet_points]}" 
      puts ""
    end
  end

end

Email.send(['abdulyoussif@gmail.com'])


