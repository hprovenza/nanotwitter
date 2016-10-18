require 'sinatra'
require 'sinatra/activerecord'
require './config/environments'
require 'bcrypt'
require './loader/loader_tokens'

use Rack::Session::Pool, :expire_after => 2592000
set :cached_id, 0

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'
require_relative 'test/test_interface'