module TweetAccess
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
    # update the timeline caches of real followers
    # invalidates the page caches of real followers
    # update current user's timeline and page cache
    info = get_tweet_info_timeline(user, tweet)
    followers = get_followers(user)
    followers.each do |f|
      update_timeline(f.id, info.to_json)
      if f.id == user.id
        cache_home_page f
      else
        reset_page_cache f.id
      end
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
end
