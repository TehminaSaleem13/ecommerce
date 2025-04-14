class Product < ApplicationRecord
  belongs_to :user
  has_many :product_images, dependent: :destroy

  accepts_nested_attributes_for :product_images, allow_destroy: true

  validates :title, :description, :price, presence: true
  validates :serial_number, uniqueness: true

  before_create :generate_unique_serial_number

  private

  def generate_unique_serial_number
    begin
      self.serial_number = SecureRandom.hex(8).upcase
    end while self.class.exists?(serial_number: serial_number)
  end
end
