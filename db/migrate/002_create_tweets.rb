class CreateTweets < ActiveRecord::Migration[4.2]
  def change
    create_table :tweets do |t|
      t.string :text
      t.integer :user_id
      t.timestamps :date
    end
  end

  def down
    drop_table :tweets
  end

end
