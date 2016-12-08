require_relative 'helper'
require_relative '../../ntclient/nanotwitter'

class ClientTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    get '/test/reset/all'
    get '/test/users/create?count=5&tweets=5'
    get '/test/user/testuser/tweets?count=5'
    get '/test/user/testuser/follow?count=3'
    @nt = NanoTwitter.new('test')
  end

  def test_setup
    assert User.all.size == 6
    assert Tweet.all.size == 30
  end

  def test_get_tweet
    test_tweet = Tweet.find_by(user_id: 0)
    puts test_tweet.id
    res = @nt.get_tweet(test_tweet.id)
    puts res
    assert res[:id] == test_tweet.id
    assert res[:user_id] == 0
  end
  
end
