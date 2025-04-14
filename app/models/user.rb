class User < ApplicationRecord
  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable
        #  , :validatable
  enum role: [:buyer, :seller]

  validates :first_name, :last_name, :email, :role, presence: true

  has_many :products, dependent: :destroy
  has_many :reviews, dependent: :destroy
  # Add this line to enable avatar attachment
  has_one_attached :avatar

  # Set full_name before saving the record
  before_save :set_full_name

  private

  # This method will concatenate first_name and last_name and set full_name
  def set_full_name
    self.full_name = "#{first_name} #{last_name}"
  end
end
