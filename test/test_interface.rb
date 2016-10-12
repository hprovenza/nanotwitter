require 'csv'
require 'faker'

helpers do
  def create_user(username, email, password)
    user = User.new({:username => username, :email => email, :password => password})
    return user
  end

  def create_testuser
    create_user("testuser", "testuser@sample.com", "password")
  end

  def delete_all
    User.delete_all
    Tweet.delete_all
    Follow.delete_all
  end

  def load_seed_user(filepath)
    CSV.foreach(filepath) do |row|
      id, first_name = row
      username = first_name.downcase
      i = 0
      while !User.find_by("username = ?", username).nil? do
        username += i.to_s
        i += 1
      end
      User.new({:id => id, :username => username, :first_name => first_name}).save
    end
  end

  def load_seed_tweet(filepath)
    CSV.foreach(filepath) do |row|
      user_id, tweet, time = row
      Tweet.new({:user_id => user_id, :text => tweet, :date => time}).save
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
end

get '/test/status' do
  testuser = User.find_by("username = ?", "testuser")
  testuser_id = nil
  if !testuser.nil?
    testuser_id = testuser.id
  end
  content_type :json
  {:users => User.all.size, :tweets => Tweet.all.size, 
    :follows => Follow.all.size, :testuser_id => testuser_id}.to_json
end

get '/test/reset/all' do
  delete_all
  testuser = create_testuser()
  testuser.save
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
  # How can we recreate testuser when the next step is loading seeds?
  # Wouldn't the testuser get overwritten?
  # create_testuser.save
  load_seed_user('./test/seeds/users.csv')
  load_seed_tweet('./test/seeds/tweets.csv')
  load_seed_follows('./test/seeds/follows.csv')
  redirect '/test/status'
end

get '/test/users/create' do
  count = [:count] || 1
  tweets = [:tweets] || 0

end
