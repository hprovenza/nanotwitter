get '/login' do
  erb :login, :locals=>{:message => nil}
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
