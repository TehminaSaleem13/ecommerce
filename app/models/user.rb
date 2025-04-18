class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable
  enum role: [:buyer, :seller]

  validates :first_name, :last_name, :email, :role, presence: true

  has_many :products, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :cart, dependent: :destroy
  has_one_attached :avatar

  before_save :set_full_name

  private

  def set_full_name
    self.full_name = "#{first_name} #{last_name}"
  end
end
