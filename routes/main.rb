get '/' do
  if session[:id].nil?
    if !page_cache_exist('index')
      cache_index_page
    end
      read_cached_page('index')
  else
    @user = User.find(session[:id])
    if !@user.nil?
      redirect '/home'
    else
      if !page_cache_exist('index')
        cache_index_page
      end
      read_cached_page('index')
    end
  end
end
