class AddSessionIdToCarts < ActiveRecord::Migration[6.1]
  def change
    add_column :carts, :session_id, :string
  end
end
