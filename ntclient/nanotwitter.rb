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

  def post_request(uri_str, params=nil)
    uri = URI.parse(uri_str)
    res = Net:HTTP.post_form(uri, params)
    puts res.body
  end

  def get_tweet(id)
    get_request("#{BASE_URI}/tweets/t/#{id}")
  end

end

n = NanoTwitter.new
puts n.get_tweet(194)

