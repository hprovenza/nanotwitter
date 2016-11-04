class AddIndexes < ActiveRecord::Migration
  def change
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
    add_index :tweets, :user_id
    add_index :follows, [:user_id, :followed_user_id], unique: true
  end
end
