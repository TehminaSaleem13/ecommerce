# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :user
  has_many :product_images, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  has_many :orders

  accepts_nested_attributes_for :product_images, allow_destroy: true

  validates :title, :description, :price, :quantity, presence: true
  validates :serial_number, uniqueness: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  before_create :generate_unique_serial_number

 
  def self.ransackable_attributes(auth_object = nil)
    ["title", "description", "created_by"]
  end
  

  def self.ransackable_associations(auth_object = nil)
    ["product_images", "user", "reviews", "cart_items", "orders"]
  end

  private

  def generate_unique_serial_number
    begin
      self.serial_number = SecureRandom.hex(8).upcase
    end while self.class.exists?(serial_number: serial_number)
  end
end