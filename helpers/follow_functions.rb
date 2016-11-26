module FollowFunctions
  def get_followers(user)
    # user: a user object
    # returns a list of users following the user
    user.followers
  end

  def get_follower_ids(user)
    followers = get_followers(user)
    followers.map {|u| u.id}
  end

  def get_followed_users(user)
    user.followed_users
  end

  def follow_exists?(follower_id, followee_id)
    f = Follow.find_by(:user_id=>follower_id, :followed_user_id=>followee_id)
    !f.nil?
  end

  def create_follow(follower_id, followee_id)
    Follow.new({:user_id=>follower_id, :followed_user_id=>followee_id}).save
    reset_timeline_cache(follower_id)
  end

  def destroy_follow(follower_id, followee_id)
    f = Follow.find_by(:user_id=>follower_id, :followed_user_id=>followee_id)
    if !f.nil? 
      f.destroy
      reset_timeline_cache(follower_id)
    end
  end
end
