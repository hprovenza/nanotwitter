require "erb"

module CacheHelper

  # module FollowFunctions
  def get_followers(user)
    # user: a user object
    # returns a list of users following the user
    user.followers
  end

  def get_follower_ids(user)
    followers = get_followers(user)
    followers.map {|u| u.id}
  end

  def get_followed_users(user)
    user.followed_users
  end

  def follow_exists?(follower_id, followee_id)
    f = Follow.find_by(:user_id=>follower_id, :followed_user_id=>followee_id)
    !f.nil?
  end

  def create_follow(follower_id, followee_id)
    Follow.new({:user_id=>follower_id, :followed_user_id=>followee_id}).save
    reset_timeline_cache(follower_id)
  end

  def destroy_follow(follower_id, followee_id)
    f = Follow.find_by(:user_id=>follower_id, :followed_user_id=>followee_id)
    if !f.nil?
      f.destroy
      reset_timeline_cache(follower_id)
    end
  end

  # module PageCache
  def cache_page(name, template, vars)
    # name: a string. Could be the name of the page. Used in the key of the cache
    # template: an ERB template
    # vars: a map of variables used in the template
    # page = erb template, :locals => vars

    bd = binding
    vars.each {|k, v| bd.local_variable_set(k, v)}
    page = ERB.new(template).result bd

    key = 'page_'+name
    $redis.set key, page
  end

  def page_cache_exists?(name)
    cache_exist 'page_'+name
  end

  def home_page_cache_exists?(user)
    name = "timeline_#{user.id}"
    page_cache_exists?(name)
  end

  def read_cached_page(name)
    key = 'page_'+name
    $redis.get key
  end

  def read_cached_home_page(user)
    name = "timeline_#{user.id}"
    read_cached_page(name)
  end

  def cache_index_page
    recent_tweets = read_recent_tweets(0, 49)
    cache_page('index', File.read(File.expand_path("../../", __dir__)+"/views/index.erb"), {:recent_tweets => recent_tweets})
  end

  def cache_home_page(user)
    timeline = read_timeline(user, 0, 49)
    name = "timeline_#{user.id}"
    cache_page(name, File.read(File.expand_path("../../", __dir__)+"/views/home.erb"), {:tl_tweets => timeline})
  end

  def cache_follower_homepages(user)
    followers = get_followers(user)
    followers.map {|u| cache_home_page(u)}
  end

  # module PassEncrypt
  def make_hash(password)
    BCrypt::Password.create(password)
  end

  def restore_password(password_hash)
    password_hash.nil? ? "" : BCrypt::Password.new(password_hash)
  end

  # module RequestAuth
  def protected!
    return if authorized?
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials \
      and user_cred_valid?(@auth.credentials[0], @auth.credentials[1])
  end

  def request_credentials
    @auth.credentials
  end

  def request_username
    @auth.credentials[0]
  end

  # module TimelineReader
  def read_timeline(user, first, last)
    # user: a user object that is the owner of the timeline
    # first: the index of the first tweet in the list to be returned
    # last: the index of the last tweet in the list to be returned
    # return a list of json objects representing tweet info
    tl_key = 'timeline_'+user.id.to_s
    if !cache_exist(tl_key)
      # initialize cache
      init_timeline_cache(user, last - first + 1)
    end
    $redis.lrange tl_key, first, last
  end

  def read_recent_tweets(first, last)
    key = 'recent'
    if !cache_exist(key)
      init_recent_cache(last - first + 1)
    end
    $redis.lrange key, first, last
  end

  def cache_exist(key)
    $redis.exists key
  end

  def reset_timeline_cache(user_id)
    $redis.del "timeline_#{user_id}"
  end

  def init_timeline_cache(user, limit)
    followed_user_ids = user.followed_users.map {|u| u.id}
    followed_tweets = Tweet.where(user_id:followed_user_ids).order(created_at: :desc).first(limit)
    # using reverse each for the correct ordering of tweets by created_at
    followed_tweets.reverse_each do |t|
      poster = User.find_by(id: t.user_id)
      info = {"text": t.text,
              "created_at": t.created_at.to_s,
              "user_id": poster.id,
              "username": poster.username
      }
      update_timeline(user.id, info.to_json)
    end
  end

  def init_recent_cache(limit)
    tweets = Tweet.order(created_at: :desc).first(limit)
    tweets.reverse_each do |t|
      poster = User.find_by(id: t.user_id)
      update_recent(poster, t)
    end
  end

  # module TweetAccess
  def find_tweet(tweet_id)
    Tweet.find_by id: tweet_id
  end

  def find_tweets_by_user(user_id, limit=10)
    tweets = Tweet.where("user_id = ?", user_id)
    if tweets.nil?
      return nil
    else
      return tweets.order(created_at: :desc).first(limit)
    end
  end

  def create_tweet(user_id, text)
    t = Tweet.new({:user_id=>user_id, :text=>text})
    return t
  end

  def get_tweet_info_api(tweet)
    info = {"id": tweet.id,
            "text": tweet.text,
            "user_id": tweet.user_id,
            "created_at": tweet.created_at.to_s
    }
    info
  end

  def get_tweet_info_timeline(user, tweet)
    info = {"text": tweet.text,
            "user_id": user.id,
            "created_at": tweet.created_at.to_s,
            "username": user.username
    }
    info
  end

  def get_recent_tweets(limit=50)
    return Tweet.order(created_at: :desc).first(limit)
  end

  def update_recent(user, tweet)
    # user: a user object
    # tweet: a tweet object
    info = get_tweet_info_timeline(user, tweet)
    cache_list("recent", info.to_json)
  end

  def update_timeline(tl_owner_id, tweet_json)
    cache_list('timeline_'+tl_owner_id.to_s, tweet_json)
  end

  def update_follower_timelines(user, tweet)
    # given a user and the tweet posted by that user
    # cache the timelines of the users forllowing this user
    info = get_tweet_info_timeline(user, tweet)
    followers = get_followers(user)
    followers.each do |f|
      update_timeline(f.id, info.to_json)
      cache_home_page(f)
    end
  end

  def cache_list(key, item, limit=50)
    # key: the key value in redis
    # item: an item in a redis list
    # limit: the size limit of the redis list
    $redis.lpush key, item
    if ($redis.llen key) > limit
      $redis.rpop key
    end
  end

  # module UserAccess
  def find_user(user_id)
    User.find_by id: user_id
  end

  def get_user_info(u)
    # u: a user object
    if u.nil?
      info = {}
    else
      info = {'id': u.id,
              'username': u.username,
              'bio': u.bio,
              'created_at': u.created_at.to_s
        }
    end
    info
  end

  def find_user_by_username(username)
    User.find_by username: username
  end

  def user_exists?(user_id)
    !find_user(user_id).nil?
  end

  def user_cred_valid?(uname, password)
    user = User.find_by(username: uname)
    !user.nil? and restore_password(user.password) == password
  end

end
