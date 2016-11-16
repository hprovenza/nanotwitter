module TimelineReader
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

  def init_timeline_cache(user, limit)
    followed_user_ids = user.followed_users.map {|u| u.id}
    # not use desc order because we need to push each tweet into the list
    # from the begining(oldest)
    followed_tweets = Tweet.where(user_id:followed_user_ids).order(:created_at).first(limit)
    followed_tweets.each do |t|
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
    tweets = Tweet.order(:created_at).first(limit)
    tweets.each do |t|
      poster = User.find_by(id: t.user_id)
      update_recent(poster, t)
    end
  end
end
