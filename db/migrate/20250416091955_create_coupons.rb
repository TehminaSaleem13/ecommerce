class CreateCoupons < ActiveRecord::Migration[6.1]
    def change
      create_table :coupons do |t|
        t.string :code
        t.float :discount
  
        t.timestamps
      end
    end
  end
  