module UserAccess
  def find_user(user_id)
    User.find_by id: user_id
  end

  def get_user_info(u)
    # u: a user object
    info = {'id': u.id,
            'username': u.username,
            'bio': u.bio,
            'created_at': u.created_at.to_s
      }
    info
  end
end
