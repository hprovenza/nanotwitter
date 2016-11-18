module TweetAccess 
  def find_tweet(tweet_id)
    Tweet.find_by id: tweet_id
  end

  def find_tweets_by_user(user_id, limit=10)
    u = Tweet.find_by(user_id: user_id)
    if u.nil?
      return nil
    else
      return u.order(:created_at, :desc).first(limit)
    end
  end

  def create_tweet(user_id, text)
    t = Tweet.new({:user_id=>user_id, :text=>text})
    return t
  end

  def update_recent(user, tweet)
    # user: a user object
    # tweet: a tweet object
    info = {"text": tweet.text,
            "created_at": tweet.created_at.to_s,
            "user_id": user.id,
            "username": user.username
    }
    cache_list("recent", info.to_json)
  end
  
  def update_timeline(tl_owner_id, tweet_json)
    cache_list('timeline_'+tl_owner_id.to_s, tweet_json)
  end

  def update_follower_timelines(user, tweet)
    # given a user and the tweet posted by that user
    # cache the timelines of the users forllowing this user
    info = {"text": tweet.text,
            "created_at": tweet.created_at.to_s,
            "user_id": user.id,
            "username": user.username
    }
    followers = get_followers(user)
    followers.each do |f|
      update_timeline(f.id, info.to_json)
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
