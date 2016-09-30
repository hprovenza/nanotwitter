class CreateTweets < ActiveRecord::Migration[4.2]
  def up
    create_table :tweets do |t|
      t.string :text
      t.integer :user_id
      t.timestamps
    end
  end

  def down
    drop_table :tweets
  end

end
