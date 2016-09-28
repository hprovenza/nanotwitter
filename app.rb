require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'

get '/' do
  erb :index
end

get '/login' do
  erb :login
end

get '/user/register' do
  erb :register
end
