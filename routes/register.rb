get '/user/register' do
  erb :register, :locals=>{:message => nil}
end

post '/user/register' do
  @user = User.new({:username=>params[:user][:username]})
  @user.password = make_hash(params[:user][:password])
  @user.id = User.count + 1
  @user.avatar_url = "/avatars/default-avatar.jpg"
  @existing = User.find_by("username = ?", params[:user][:username])
  if !@existing.nil?
    erb :register, :locals=>{:message =>
      Messages::USER_ALREADY_EXIST}
  elsif @user.save
    Follow.new({:user_id=>@user.id, :followed_user_id=>@user.id}).save
    redirect '/user/register/success'
  else
    Messages::OTHER_ERRORS
  end
end

get '/user/register/success' do
  erb :register_success
end
