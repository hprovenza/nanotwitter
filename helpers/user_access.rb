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

  def find_user_by_username(username)
    User.find_by username: username
  end

  def user_cred_valid?(uname, password)
    user = User.find_by(username: uname)
    !user.nil? and restore_password(user.password) == password
  end
end
