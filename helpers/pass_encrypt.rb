require 'bcrypt'

module PassEncrypt
  def make_hash(password)
    BCrypt::Password.create(password)
  end

  def restore_password(password_hash)
    BCrypt::Password.new(password_hash)
  end
end