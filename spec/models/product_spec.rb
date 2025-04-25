require 'rails_helper'

RSpec.describe Product, type: :model do
  let(:user) { create(:user, role: :seller) }

  describe "associations" do
    it { should belong_to(:user) }
    it { should have_many(:product_images).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than_or_equal_to(0) }

   
  end

  describe "callbacks" do
    it "generates a unique serial number before create" do
      product = build(:product, user: user)
      expect(product.serial_number).to be_nil

     
      allow(SecureRandom).to receive(:hex).with(8).and_return("abcdef12")

      product.save

     
      expect(product.serial_number).to eq("ABCDEF12")
    end

    context "when a serial number already exists" do
      it "generates a new one until unique" do
       
        existing_product = create(:product, user: user)

        new_product = build(:product, user: user)

       
        hex_sequence = ["abcdef12", "98765432"]
        hex_sequence.each do |hex|
          allow(SecureRandom).to receive(:hex).with(8).and_return(hex)
        end

        new_product.save

        
        expect(new_product.serial_number).to eq("98765432".upcase)
      end
    end
  end
end
