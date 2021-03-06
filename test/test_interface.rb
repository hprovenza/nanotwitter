require 'csv'
require 'faker'
require 'bcrypt'

helpers do
  def create_user(username, email, password)
    user = User.new({:username => username,
                     :email => email,
                     :password => make_hash(password)})
    Follow.new({:user_id => user.id, :followed_user_id => user.id}).save
    return user
  end

  def create_testuser
    user = create_user("testuser", "testuser@sample.com", "password")
    user.id = 0
    return user
  end

  def delete_all
    User.delete_all
    Tweet.delete_all
    Follow.delete_all
    $redis.flushall
  end

  def test_tweet(user_id)
    Tweet.new({:user_id => user_id, :text => 'test text'}).save
  end

  def load_seed_user(filepath)
    CSV.foreach(filepath) do |row|
      id, first_name = row
      username = first_name.downcase
      if !User.find_by("username = ?", username).nil?
        i = 2
        username += i.to_s
        while !User.find_by("username = ?", username).nil? do
          i += 1
          username[-1] = i.to_s
        end
      end
      user = User.new({:id => id, :username => username, :first_name => first_name, :password => make_hash('password')})
      user.save
      Follow.new({:user_id => user.id, :followed_user_id => user.id}).save
    end
  end

  def load_seed_tweet(filepath)
    CSV.foreach(filepath) do |row|
      user_id, tweet, time = row
      t = Tweet.new({:user_id => user_id, :text => tweet,
        :created_at => time, :updated_at => time})
      t.save
    end
  end

  def load_seed_follows(filepath)
    CSV.foreach(filepath) do |row|
      user_id, followed_user_id = row
      Follow.new({:user_id => user_id, :followed_user_id => followed_user_id}).save
    end
  end

  def fake_username
    Faker::Internet.user_name
  end

  def fake_email
    Faker::Internet.email
  end

  def fake_tweet
    Faker::Lorem.sentence
  end
end

get '/test/status' do
  testuser = User.find_by("username = ?", "testuser")
  testuser_id = testuser.nil? ? nil : testuser.id
  content_type :json
  {:users => User.all.size, :tweets => Tweet.all.size,
    :follows => Follow.all.size, :testuser_id => testuser_id}.to_json
end

get '/test/reset/all' do
  delete_all
  create_testuser.save
  redirect '/test/status'
end

get '/test/reset/testuser' do
  testuser = User.find_by("username = ?", "testuser")
  testuser.destroy
  create_testuser.save
  redirect '/test/status'
end

get '/test/reset/standard' do
  delete_all
  create_testuser.save
  load_seed_user('./test/seeds/users.csv')
  load_seed_tweet('./test/seeds/tweets.csv')
  load_seed_follows('./test/seeds/follows.csv')
  redirect '/test/status'
end

get '/test/users/create' do
  count = (params[:count] || 1).to_i
  tweets = (params[:tweets] || 0).to_i
  while count > 0 do
    user = User.new({:username => fake_username, :email => fake_email})
    user.save
    count -= 1
    tweets_each = tweets
    while tweets_each > 0 do
      Tweet.new({:user_id => user.id, :text => fake_tweet}).save
      tweets_each -= 1
    end
  end
  redirect '/test/status'
end

get '/test/user/:user_name/tweets' do
  count = (params[:count] || 0).to_i
  user = User.find_by("username = ?", params[:user_name])
  if !user.nil?
    while count > 0 do
      Tweet.new({:user_id => user.id, :text => fake_tweet}).save
      count -= 1
    end
  end
  redirect '/test/status'
end

get '/test/user/:user_name/follow' do
  count = (params[:count] || 0).to_i
  user = User.find_by("username = ?", params[:user_name])
  if !user.nil?
    while count > 0 do
      followed_user_id = 1 + rand(User.all.size - 1)
      if followed_user_id != user.id && Follow.find_by(user_id: user.id, followed_user_id: followed_user_id).nil?
        Follow.new({:user_id => user.id, :followed_user_id => followed_user_id}).save
        count -= 1
      end
    end
  end
end
