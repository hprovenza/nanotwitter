get "#{$API_PREFIX}/tweets/t/:tweet_id" do
  t = find_tweet params[:tweet_id].to_i
  if t.nil?
    return {}.to_json
  else
    info = {'id': t.id,
            'text': t.text,
            'created_at': t.created_at.to_s,
            'user_id': t.user_id
    }
    return info.to_json
  end
end 

get "#{$API_PREFIX}/tweets/recent" do
  'not implemented'
end

post "#{$API_PREFIX}/tweets/update" do
  protected!
  u = find_user_by_username(request_username)
  t = create_tweet(u.id, params[:text])
  t.save
  update_recent(u, t)
  cache_index_page
  update_follower_timelines(u, t)
  get_tweet_info_api(t).to_json
end
