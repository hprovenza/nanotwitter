require 'aws-sdk'

get '/home' do
  if session[:id].nil?
    redirect '/'
  end
  @user = User.find(session[:id])
  if @user.nil?
    redirect '/'
  else
    erb :home
  end
end

post '/home' do
  @user = User.find(session[:id])
  t = create_tweet(@user.id, params[:tweet]) 
  t.save
  cache_recent(@user, t)
  # TODO: get_followers
  # for each follower
  #   cache_timeline
  followers = get_followers(@user)

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
      "user does not exist!"
    end
  end
end

get '/browse' do
  if session[:id].nil? || User.find(session[:id]).nil?
    redirect '/login'
  else
    erb :browse
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
      "user does not exist!"
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
      "user does not exist!"
    end
  end
end

post '/update_bio' do
  @user = User.find(session[:id])
  @user.bio = params[:bio]
  @user.save
  @msg_success = "Your bio is now updated"
  erb :settings
end

post '/update_password' do
  @user = User.find(session[:id])
  if !params[:old_password].empty? &&
    restore_password(@user.password) == params[:old_password]
    @user.password = make_hash(params[:new_password])
    @user.save
    @msg_success = "Your password is now updated"
    erb :settings
  else
    @msg_fail = "Your old password is incorrect"
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
  erb :settings
end
