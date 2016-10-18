get '/' do
  if session[:id].nil?
    erb :index
  else
    @user = User.find(session[:id])
    if !@user.nil?
      redirect '/home'
    else
      erb :index
    end
  end
end