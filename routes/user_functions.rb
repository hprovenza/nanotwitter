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
  Tweet.new({:text=>params[:tweet], :user_id=>@user.id}).save
  erb :home
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
  erb :settings
end

post '/settings' do
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