module UserAccess
  def find_user(user_id)
    User.find_by id: user_id
  end
end
