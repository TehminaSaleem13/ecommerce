class ChangeQuantityDefaultInProducts < ActiveRecord::Migration[6.0]
  def change
    change_column_default :products, :quantity, from: nil, to: 0
  end
end
