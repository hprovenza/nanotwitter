require 'net/http'

class NanoTwitter
  API_VER = "v1"
  BASE_URI = "https://reptilesplash.herokuapp.com/api/#{API_VER}"
  TEST_BASE_URI = "http://localhost:4567/api/#{API_VER}"
  
  def get_request(uri_str, params=nil)
    # uri_str: unparsed string of request url
    uri = URI.parse(uri_str)
    if !params.nil?
      uri.query = URI.encode_www_form(params)
    end
    res = Net::HTTP.get_response(uri)
    res.body if res.is_a?(Net::HTTPSuccess)
  end

  def post_request(uri_str, params)
    uri = URI.parse(uri_str)
    res = Net:HTTP.post_form(uri, params)
    res
  end

  def post_with_auth(uri_str, params, username, password)
    uri = URI.parse(uri_str)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(params)
    req.basic_auth(username, password)

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    res.body
  end

  def get_tweet(id)
    get_request("#{BASE_URI}/tweets/t/#{id}")
  end

  def post_tweet(text, username, password)
    req_uri = "#{BASE_URI}/tweets/update"
    params = {:text => text}
    post_with_auth(req_uri, params, username, password)
  end
end
