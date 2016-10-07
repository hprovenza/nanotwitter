require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/follow'
require './models/tweet'
require './models/user'
require 'bcrypt'

#enable :sessions
use Rack::Session::Pool, :expire_after => 2592000
set :cached_id, 0

helpers do
  def make_hash(password)
    BCrypt::Password.create(password)
  end

  def restore_password(password_hash)
    BCrypt::Password.new(password_hash)
  end

end

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

get '/user/register' do
  erb :register, :locals=>{:message => nil}
end

# routes that need authorization
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

get '/logout' do
  session.clear
  erb :logout
end

post '/user/register' do
  @user = User.new({:username=>params[:user][:username]})
  @user.password = make_hash(params[:user][:password])
  @existing = User.find_by("username = ?", params[:user][:username])
  if !@existing.nil?
    erb :register, :locals=>{:message =>
      "Account already exists! Try a new username or log back in!"}
  elsif @user.save
    Follow.new({:user_id=>@user.id, :followed_user_id=>@user.id}).save
    redirect '/user/register/success'
  else
    "Sorry our server is taking a nap"
  end
end

get '/user/register/success' do
  erb :register_success
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
