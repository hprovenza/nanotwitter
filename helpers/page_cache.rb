module PageCache
  def cache_page(name, template, vars)
    # name: a string. Could be the name of the page. Used in the key of the cache
    # template: an ERB template
    # vars: a map of variables used in the template
    page = erb template, :locals => vars
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

  def reset_page_cache(user_id)
    $redis.del "page_timeline_#{user_id}"
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
    cache_page('index', :index, {:recent_tweets => recent_tweets})
  end

  def cache_home_page(user)
    timeline = read_timeline(user, 0, 49)
    name = "timeline_#{user.id}"
    cache_page(name, :home, {:tl_tweets => timeline})
  end

  def cache_follower_homepages(user)
    followers = get_followers(user)
    followers.map {|u| cache_home_page(u)}
  end
end
