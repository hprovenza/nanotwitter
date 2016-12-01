get '/login' do
  username = params[:username]
  password = params[:password]
  random_tweet_prob = params[:randomtweet].to_i #0-100
  if username.nil? || password.nil?
    erb :login, :locals=>{:message => nil}
  else
    @user = User.find_by(username: username)
    if @user.nil?
      erb :login, :locals=>{:message => Messages::USER_NOT_EXIST}
    elsif restore_password(@user.password) != password
      erb :login, :locals=>{:message => Messages::WRONG_PASSWORD}
    elsif random_tweet_prob.nil? || rand(100) > random_tweet_prob
      session[:id] = @user.id
      redirect '/home'
    else
      session[:id] = @user.id
      t = create_tweet(@user.id, rand(10))
      t.save
      update_recent(@user, t)
      cache_home_page(@user)
      cache_index_page
      # update the cache for the timeline of each follower
      update_follower_timelines(@user, t)
      redirect '/home'
    end
  end
end

post '/login' do
  @user = User.find_by(username: params[:user][:username])
  if @user.nil?
    erb :login, :locals=>{:message => Messages::USER_NOT_EXIST}
  elsif restore_password(@user.password) != params[:user][:password]
    erb :login, :locals=>{:message => Messages::WRONG_PASSWORD}
  else
    session[:id] = @user.id
    redirect '/home'
  end
end

get '/logout' do
  session.clear
  erb :logout
end
