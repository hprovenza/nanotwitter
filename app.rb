require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/user'

enable :sessions

get '/' do
  erb :index
end

get '/login' do
  erb :login
end

post '/login/submit' do
  @user = User.find_by(username: params[:user][:username], password: params[:user][:password])
  if @user.nil?
    "Either username does not exist or wrong password"
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

post '/user/register' do
  @user = User.new(params[:user])
  @existing = User.find_by("username = ?", params[:user][:username])
  if !@existing.nil?
    erb :register, :locals=>{:message =>
      "Account already exists! Try a new username or log back in!"}
  elsif @user.save
    redirect '/user/register/success'
  else
    "Sorry our server is taking a nap"
  end
end

get '/user/register/success' do
  erb :register_success
end
