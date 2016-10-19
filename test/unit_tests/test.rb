require_relative 'test_helper'

class NTTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    get '/test/reset/all'
  end

  def test_main_page
    get '/'
    assert last_response.ok?
  end

  def test_user_number
    assert User.all.size == 1
  end

  def test_register
    get '/user/register'
    assert last_response.ok?
    post '/user/register', {:user=>{:username=>'testuser', :password=> 'password'}}
    assert User.all.size == 1
    post '/user/register', {:user=>{:username=>'test', :password=> 'test'}}
    assert User.all.size == 2
  end

  def test_login
    get '/login'
    assert last_response.ok?
    post '/login', {:user=>{:username=>'test', :password=> 'test'}}
    assert last_response.ok?
  end
end