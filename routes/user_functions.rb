require 'aws-sdk'

get '/home' do
  if session[:id].nil?
    redirect '/'
  end
  @user = User.find(session[:id])
  if @user.nil?
    redirect '/'
  else
    if !home_page_cache_exists?(@user)
      cache_home_page(@user)
    end
    read_cached_home_page(@user)
  end
end

post '/home' do
  @user = User.find(session[:id])
  t = create_tweet(@user.id, params[:tweet])
  t.save
  # # only updating followers' timelines since the user is a follower of themself.
  # update_follower_timelines(@user, t)
  # cache_follower_homepages(@user)
  # update_recent(@user, t)
  # cache_index_page

  $channel.default_exchange.publish(session[:id].to_s + "-|SEP|-" + t.id.to_s, :routing_key => $q.name)

  redirect '/home'
end

get '/user/:id' do
  if session[:id].nil? || User.find(session[:id]).nil?
    redirect '/login'
  else
    @user = User.find_by("id = ?", params[:id].to_i)
    if @user
      settings.cached_id = params[:id]
      erb :user
    else
      Messages::USER_NOT_EXIST
    end
  end
end

get '/browse' do
  if session[:id].nil? || User.find(session[:id]).nil?
    redirect '/login'
  else
    recent_tweets = read_recent_tweets(0, 49)
    erb :browse, :locals => {:recent_tweets => recent_tweets}
  end
end

post '/update_relation' do
  if params[:status] == "Follow"
    f = Follow.new({:user_id=>session[:id], :followed_user_id=>settings.cached_id})
    !f.nil? ? f.save : "Error saving new follow"
  elsif params[:status] == "Unfollow"
    d = Follow.find_by(:user_id=>session[:id], :followed_user_id=>settings.cached_id)
    !d.nil? ? d.destroy : "Error deleting follow"
  end
  # need to reset timeline cache here
  reset_timeline_cache session[:id]
  @user = User.find session[:id]
  init_timeline_cache @user, 50
  cache_home_page @user

  reset_page_cache settings.cached_id
  # @followed_user = User.find settings.cached_id
  # init_timeline_cache @followed_user, 50
  # cache_home_page @followed_user
  redirect "/user/#{settings.cached_id}"
end

get '/settings' do
  if session[:id].nil?
    redirect '/login'
  end
  @user = User.find(session[:id])
  if @user.nil?
    redirect '/login'
  else
    erb :settings
  end
end

post '/settings' do
  @user = User.find(session[:id])
  erb :settings
end

get '/user/:id/following' do
  if session[:id].nil? || User.find(session[:id]).nil?
    redirect '/login'
  else
    @user = User.find_by("id = ?", params[:id].to_i)
    if @user
      settings.cached_id = params[:id]
      erb :following
    else
      Messages::USER_NOT_EXIST
    end
  end
end

get '/user/:id/followers' do
  if session[:id].nil? || User.find(session[:id]).nil?
    redirect '/login'
  else
    @user = User.find_by("id = ?", params[:id].to_i)
    if @user
      settings.cached_id = params[:id]
      erb :followers
    else
      Messages::USER_NOT_EXIST
    end
  end
end

post '/update_bio' do
  @user = User.find(session[:id])
  @user.bio = params[:bio]
  @user.save
  @msg_success = Messages::UPDATE_BIO
  erb :settings
end

post '/update_password' do
  @user = User.find(session[:id])
  if !params[:old_password].empty? &&
    restore_password(@user.password) == params[:old_password]
    @user.password = make_hash(params[:new_password])
    @user.save
    @msg_success = Messages::UPDATE_PASSWORD
    erb :settings
  else
    @msg_fail = Messages::WRONG_PASSWORD
    erb :settings
  end
end

post '/update_pic' do
  @user = User.find(session[:id])
  file       = params[:file][:tempfile]
  cred = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
  s3 = Aws::S3::Resource.new(
      region: ENV['AWS_REGION'],
      credentials: cred)
  obj = s3.bucket('reptilesplash-profilephotos').object('pfpics' + '/' + @user.username)
  obj.upload_file(file)
  @user.avatar_url = obj.public_url(virtual_host: true)
  erb :settings
end
