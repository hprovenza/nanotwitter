require 'sinatra'
require 'sinatra/activerecord'
require_relative 'config/environments'
require 'bcrypt'
require_relative 'loader/loader_tokens'

use Rack::Session::Pool, :expire_after => 2592000
set :cached_id, 0
api_version = 'v1'

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'
require_relative "api/#{api_version}/init"
require_relative 'test/test_interface'
