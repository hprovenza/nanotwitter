require_relative 'helper'

class NTTest2 < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    get '/test/reset/all'
    post '/user/register', {:user=>{:username=>'test', :password=> 'test'}}
    post '/login', {:user=>{:username=>'test', :password=> 'test'}}
  end

  def test_follow
    post '/update_relation', {:status=>'Follow', :user_id=>1, :followed_user_id=>0}
    assert Follow.all.size == 3
  end

  def test_unfollow
    test_follow
    post '/update_relation', {:status=>'Unfollow', :user_id=>1, :followed_user_id=>0}
    assert Follow.all.size == 2
  end

end
