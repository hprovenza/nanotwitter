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

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    # first try, would probably need fix
    if @auth.provided? && @auth.basic? && @auth.credentials
      # need migration first
      user = User.find_by(name: @auth.credentials[0], password: @auth.credentials[1])
      return !user.nil?
    else
      return false
    end
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