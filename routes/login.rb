get '/login' do
  erb :login, :locals=>{:message => nil}
end

post '/login' do
  @user = User.find_by(username: params[:user][:username])
  if @user.nil?
    erb :login, :locals=>{:message =>
      "User does not exist"}
  elsif restore_password(@user.password) != params[:user][:password]
    erb :login, :locals=>{:message =>
      "Wrong password"}
  else
    session[:id] = @user.id
    redirect '/home'
  end
end

get '/logout' do
  session.clear
  erb :logout
end