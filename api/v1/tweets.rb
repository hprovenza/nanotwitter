get "#{$API_PREFIX}/tweets/:tweet_id" do
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

