require 'sinatra'
require 'sinatra/activerecord'
require_relative 'config/environments'
require 'bcrypt'
require_relative 'loader/loader_tokens'
require 'puma'

use Rack::Session::Pool, :expire_after => 2592000
set :cached_id, 0
#set web server here
# set :server, 'puma'

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'
require_relative 'test/test_interface'
