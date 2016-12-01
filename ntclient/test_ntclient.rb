require 'minitest/autorun'
require 'rack/test'
require_relative './ntclient'
require_relative '../app'

class NTTest2 < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    $nt = NanoTwitter.new
  end

  def test_get_testuser
    testuser = $nt.get_user 0
    assert testuser['id'] == 0
    assert testuser['username'] == 'testuser'
  end

  def test_get_followed_users
    followed_users = $nt.get_followed_users 0
    assert followed_users == []
  end

  def test_get_followers
    followers = $nt.get_followers 0
    assert followers == []
  end

  def test_get_tweet
    tweet = $nt.get_tweet 0
    assert tweet == {}
  end

  def test_get_user_tweets
    tweets = $nt.get_user_tweets 0
    assert tweets == []
  end

end
