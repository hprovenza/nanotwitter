class User < ActiveRecord::Base
  has_many :tweets
  has_many :follows
  has_many :followed_users, :through => :follows
  has_many :followings, :class_name => "Follow",
    :foreign_key => :followed_user_id
  has_many :followers, :through => :followings, :source => :user
end
