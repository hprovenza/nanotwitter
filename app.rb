require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require './models/user'

# might need to implement sessions?
helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  # def authorized?
  #   @auth ||=  Rack::Auth::Basic::Request.new(request.env)
  #   # first try, would probably need fix
  #   if @auth.provided? && @auth.basic? && @auth.credentials
  #     # need migration first
  #     user = User.find_by(username: @auth.credentials[0], password: @auth.credentials[1])
  #     return !user.nil?
  #   else
  #     return false
  #   end
  # end
  def authorized?
    #return User.where("username = ? AND password = ?", params[:user][:username], params[:user][:password]).nil?
  end

end




get '/' do
  erb :index
end

get '/login' do
  erb :login
end

get '/user/register' do
  erb :register
end

# routes that need authorization
get '/home' do
  if authorized?
    erb :home
  else
    redirect '/'
  end
end

post '/add_user' do
  @user = User.new(params[:user])
  @existing = User.where("username = ?", params[:user][:username])
  if !@existing.nil?
    "This username already exists!"
  elsif @user.save
    redirect '/user/register/success'
  else
    "Sorry, there was an error"
  end
end

get '/user/register/success' do
  erb :register_success
end
