get "#{$API_PREFIX}/users/:user_id" do
  u = find_user(params[:user_id].to_i)
  if u.nil?
    return {}.to_json
  else
    info = get_user_info(u)
    return info.to_json
  end
end

get "#{$API_PREFIX}/users/:user_id/tweets" do
  tweets = find_tweets_by_user(params[:user_id].to_i)
  if tweets.nil?
    return [].to_json
  else
    t_list = Array.new
    tweets.each do |t|
      t_list << get_tweet_info(t)
    end
    return t_list.to_json
  end
end

get "#{$API_PREFIX}/users/:user_id/following" do
  u = find_user(params[:user_id].to_i)
  if u.nil?
    return [].to_json
  else
    followed_users = get_followed_users(u)
    f_list = Array.new
    followed_users.each do |f|
      # ignore the user themself since each user
      # is following themself in the database
      if f.id != u.id
        f_list << get_user_info(f)
      end
    end
    return f_list.to_json
  end
end

get "#{$API_PREFIX}/users/:user_id/followers" do
  u = find_user(params[:user_id].to_i)
  if u.nil?
    return [].to_json
  else
    followers = get_followers(u)
    f_list = Array.new
    #TODO
    followers.each do |f|
      f_list << get_user_info(f)
    end
    return f_list.to_json
  end
end

