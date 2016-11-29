module RequestAuth
  def protected!
    return if authorized?
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||= Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials \
      and user_cred_valid?(@auth.credentials[0], @auth.credentials[1])
  end

  def request_credentials
    @auth.credentials
  end

  def request_username
    @auth.credentials[0]
  end
end
