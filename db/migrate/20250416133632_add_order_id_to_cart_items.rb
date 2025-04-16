class AddOrderIdToCartItems < ActiveRecord::Migration[6.1]
  def change
    add_reference :cart_items, :order, null: true, foreign_key: true
  end
end
