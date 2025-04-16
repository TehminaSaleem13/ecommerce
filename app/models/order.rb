class Order < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :nullify # optional — snapshot behavior
  enum status: { pending: 'pending', paid: 'paid', failed: 'failed' }
end
