module UserCache
  def user_cache_exists?(username)
    cache_exist 'user_'+username
  end

  def get_cached_user(username)
    # read from cache and deserialize the user object
    if username.nil? || !user_cache_exists?(username)
      return nil
    end
    key = 'user_'+username
    Marshal::load($redis.get key)
  end

  def cache_user(user_obj)
    # serialize user in binary form and cache in redis
    if user_obj.nil?
      return nil
    end
    key = 'user_'+user_obj.username
    $redis.set key, Marshal::dump(user_obj)
    user_obj
  end
end
