get '/search' do
  if session[:id].nil?
    redirect '/login'
  end
  @user = User.find(session[:id])
  if @user.nil?
    redirect '/login'
  else
    @query = params[:query]
    @match_tweet = @query.nil? ? "" : (@query.split.map {|s| "\\y"+s+"\\y"}).join(".+")
    @tweet_results = Tweet.where("text ~* ?", @match_tweet).take(50)
    @username = params[:username]
    @match_username = @username.nil? ? "" : "%"+@username+"%"
    @user_results = @username.nil? ? [] : User.where("username LIKE ?", @match_username).take(50)
    erb :search
  end
end
