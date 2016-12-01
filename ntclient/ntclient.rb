require 'net/http'
require 'json'

class NanoTwitter
  API_VER = "v1"
  PROD_URI = "https://reptilesplash.herokuapp.com/api/#{API_VER}"
  TEST_URI = "http://localhost:4567/api/#{API_VER}"
  def initialize(env='prod')
    @env = env 
    if @env == 'prod'
      @base_uri = PROD_URI
    else
      @base_uri = TEST_URI
    end
  end
  
  def get_request(uri_str, params=nil)
    # uri_str: unparsed string of request url
    uri = URI.parse(uri_str)
    if !params.nil?
      uri.query = URI.encode_www_form(params)
    end
    res = Net::HTTP.get_response(uri)
    
    if res.is_a?(Net::HTTPSuccess)
      res.body
    else
      raise 'unexpected response'
    end
  end

  def post_request(uri_str, params)
    uri = URI.parse(uri_str)
    res = Net:HTTP.post_form(uri, params)
    
    res.body
  end

  def post_with_auth(uri_str, params, username, password)
    uri = URI.parse(uri_str)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(params)
    req.basic_auth(username, password)
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    res = http.request(req)
    
    if res.is_a?(Net::HTTPSuccess)
      res.body
    elsif res.is_a?(Net::HTTPUnauthorized)
      raise 'Wrong username or password'
    else
      puts res.class
      raise 'unexpected response'
    end
  end

  def parse_response(res)
    JSON.parse(res)
  end

  def get_tweet(tweet_id)
    res = get_request("#{@base_uri}/tweets/t/#{tweet_id}")
    parse_response(res)
  end

  def get_user(user_id)
    res = get_request("#{@base_uri}/users/u/#{user_id}")
    parse_response(res)
  end

  def get_followed_users(user_id)
    res = get_request("#{@base_uri}/users/u/#{user_id}/following")
    parse_response(res)
  end

  def get_followers(user_id)
    res = get_request("#{@base_uri}/users/u/#{user_id}/followers")
    parse_response(res)
  end

  def get_user_tweets(user_id)
    res = get_request("#{@base_uri}/users/u/#{user_id}/tweets")
    parse_response(res)
  end

  def follow_user(followee_id, username, password)
    # followee_id: the id of the user to be followed
    # username: the username of the user who will be following the followee
    # password: the password for the following user
    # returns the info about the followed user, empty hash if user does not 
    # exist
    req_uri = "#{@base_uri}/users/follow"
    params = {:user_id=>followee_id}
    res = post_with_auth(req_uri, params, username, password)
    parse_response(res)
  end

  def unfollow_user(followee_id, username, password)
    # followee_id: the id of the user to be unfollowed
    # username: the username of the user who will be unfollowing the followee
    # password: the password for the following user
    # returns the info about the followed user, empty hash if user does not 
    # exist
    req_uri = "#{@base_uri}/users/unfollow"
    params = {:user_id=>followee_id}
    res = post_with_auth(req_uri, params, username, password)
    parse_response(res)
  end

  def post_tweet(text, username, password)
    req_uri = "#{@base_uri}/tweets/update"
    params = {:text => text}
    res = post_with_auth(req_uri, params, username, password)
    parse_response(res)
  end
end
