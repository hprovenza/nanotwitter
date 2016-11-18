get "#{$API_PREFIX}/users/:user_id" do
  u = find_user(params[:user_id].to_i)
  if u.nil?
    return {}.to_json
  else
    info = {'id': u.id, 
            'username': u.username,
            'bio': u.bio,
            'created_at': u.created_at.to_s
    }
    return info.to_json
  end
end

get "#{$API_PREFIX}/users/:user_id/tweets" do
  tweets = find_tweets_by_user(params[:user_id].to_i)
  if tweets.nil?
    return {}.to_json
  else
    #TODO
  end
end
