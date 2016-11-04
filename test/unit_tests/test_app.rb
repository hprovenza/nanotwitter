require_relative 'helper'

class TestUserSession < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_user_session
    get '/', {}, {'rack.session' => {user_id: test_user.id}}
  end

  def test_user
    User.find_by(username: 'testuser')
  end

  def setup
    get '/test/reset/all'
    test_user_session
  end
end

class UserTest < TestUserSession
  def test_session
    get '/'
    assert_equal test_user.id, last_request.env['rack.session']['user_id']
    assert last_response.ok?
  end

  
  def test_login
    get '/login'
    assert last_response.ok?
    post '/login', {:user=>{:username=>'testuser', :password=> 'password'}}
    follow_redirect!
    assert last_response.ok?
    assert_equal test_user.id, last_request.env['rack.session']['user_id']
  end

  def test_posting
    assert_equal 0, Tweet.all.size
    post '/home', {:tweet => 'test tweet', :user_id => test_user.id}, {'rack.session' => {:id => test_user.id}}
    assert_equal 1, Tweet.all.size
    assert_equal 'test tweet', Tweet.find_by("user_id=?", test_user.id).text
    follow_redirect!
    assert last_response.ok?
  end
end

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

  def test_tweet
    post '/login', {:user=>{:username=>'testuser', :password=> 'password'}}
    post '/home', {:tweet=>'hello world', :user_id=>0}
    assert Tweet.all.size == 1
    assert Tweet.take.text == 'hello world'
  end

  def test_view_tweets
    post '/login', {:user=>{:username=>'testuser', :password=> 'password'}}
    get '/user/0'
    assert last_response.ok?
    assert last_response.body != 'user does not exist!'
    get '/user/999999999999'
    assert last_response.ok?
    assert last_response.body == 'user does not exist!'
  end
end