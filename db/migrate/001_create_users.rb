class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password
      t.string :bio
      t.string :avatar_url
      t.timestamps
    end
  end

  def down
    drop_table :users
  end

end
