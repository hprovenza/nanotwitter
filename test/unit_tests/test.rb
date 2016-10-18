require_relative 'test_helper'

class NTTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_main_page
    get '/'
    assert last_response.ok?
  end
end