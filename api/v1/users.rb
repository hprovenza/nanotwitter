get "#{$API_PREFIX}/users/u/:user_id" do
  u = find_user(params[:user_id].to_i)
  if u.nil?
    return {}.to_json
  else
    info = get_user_info(u)
    return info.to_json
  end
end

get "#{$API_PREFIX}/users/u/:user_id/tweets" do
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

get "#{$API_PREFIX}/users/u/:user_id/following" do
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

get "#{$API_PREFIX}/users/u/:user_id/followers" do
  u = find_user(params[:user_id].to_i)
  if u.nil?
    return [].to_json
  else
    followers = get_followers(u)
    f_list = Array.new
    followers.each do |f|
      f_list << get_user_info(f)
    end
    return f_list.to_json
  end
end

post "#{$API_PREFIX}/users/follow" do
  protected!
  u = find_user_by_username(request_username)
  followee_id = params[:user_id]
  if !follow_exists?(u.id, followee_id) and user_exists?(followee_id)
    create_follow(u.id, followee_id)
  end
  get_user_info(find_user(followee_id)).to_json
end

post "#{$API_PREFIX}/users/unfollow" do
  protected!
  u = find_user_by_username(request_username)
  followee_id = params[:user_id]
  if follow_exists?(u.id, followee_id)
    destroy_follow(u.id, followee_id)
  end
  get_user_info(find_user(followee_id)).to_json
end
