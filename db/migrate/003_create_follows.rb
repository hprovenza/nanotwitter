class CreateFollows < ActiveRecord::Migration[4.2]
  def up
    create_table :follows do |t|
      t.integer :user_id
      t.integer :followed_user_id
      t.timestamps
    end
  end

  def down
    drop_table :follows
  end

end
