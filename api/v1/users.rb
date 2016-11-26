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
  return tweets.map{ |t| get_tweet_info_api t }.to_json
end

get "#{$API_PREFIX}/users/u/:user_id/following" do
  u = find_user(params[:user_id].to_i)
  if u.nil?
    return [].to_json
  else
    followed_users = get_followed_users(u)
    return followed_users.map{ |f| get_user_info f }.to_json
  end
end

get "#{$API_PREFIX}/users/u/:user_id/followers" do
  u = find_user(params[:user_id].to_i)
  if u.nil?
    return [].to_json
  else
    followers = get_followers(u)
    return followers.map{ |f| get_user_info f }.to_json
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
