class DropUsersTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :users if table_exists?(:users)
  end

  def down
    create_table :users do |t|
      # Define the columns you would need if you were to recreate this table
      # For example:
      # t.string :name
      # t.string :email
      
      t.timestamps
    end
  end
end