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
end
