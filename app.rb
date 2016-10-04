require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/follow'
require './models/tweet'
require './models/user'

#enable :sessions
use Rack::Session::Pool, :expire_after => 2592000

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
  @user = User.find_by(username: params[:user][:username],
      password: params[:user][:password])
  if @user.nil?
    erb :login, :locals=>{:message =>
      "Either username does not exist or wrong password"}
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
  @user = User.new(params[:user])
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
