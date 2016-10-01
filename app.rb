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
  user = User.find_by(email: params["email"], password: params["password"])
  if user.nil?
    # loggin failed page
  else
    session[:id] = user.id
    redirect '/home'
  end
end

get '/user/register' do
  erb :register, :locals=>{:message => nil}
end

# routes that need authorization
get '/home' do
  if sesssion[:id].nil?
    redirect '/login'
  end
  @user = User.find(session[:id])
  if @user.nil?
    redirect '/login'
  else
    erb :home
  end
end

post '/user/register' do
  @user = User.new(params[:user])
  @existing = User.where("username = ?", params[:user][:username])
  if @existing.count != 0
    erb :register, :locals=>{:message =>
      "Account already exists! Try a new username or log back in!"}
  elsif @user.save
    redirect '/user/register/success'
  else
    "Sorry our server died..."
  end
end

get '/user/register/success' do
  erb :register_success
end
