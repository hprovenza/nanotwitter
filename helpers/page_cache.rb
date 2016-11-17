module PageCache
  def cache_page(name, template, vars)
    # name: a string. Could be the name of the page. Used in the key of the cache
    # template: an ERB template
    # vars: a map of variables used in the template
    page = erb template, :locals => vars
    key = 'page_'+name
    $redis.set key, page
  end
  
  def page_cache_exist(name)
    cache_exist 'page_'+name
  end

  def read_cached_page(name)
    key = 'page_'+name
    $redis.get key
  end

  def cache_index_page
    recent_tweets = read_recent_tweets(0, 49)
    cache_page('index', :index, {:recent_tweets => recent_tweets})
  end
end
