module PostTweet 
  def create_tweet(user_id, text)
    t = Tweet.new({:user_id=>user_id, :text=>text})
    return t
  end

  def cache_recent(user, tweet)
    # user: a user object
    # tweet: a tweet object
    info = {"text": tweet.text,
            "created_at": tweet.created_at.to_s,
            "user_id": user.id,
            "username": user.username
    }
    cache_list("recent", info.to_json)
  end

  def cache_follower_timelines(user, tweet)
    # given a user and the tweet posted by that user
    # cache the timelines of the users forllowing this user
    info = {"text": tweet.text,
            "created_at": tweet.created_at.to_s,
            "user_id": user.id,
            "username": user.username
    }
    followers = get_followers(user)
    followers.each do |f|
      cache_list("timeline_"+f.username, info.to_json, limit=100)
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

  def cache_exist(key)
    $redis.exists key
  end
end
