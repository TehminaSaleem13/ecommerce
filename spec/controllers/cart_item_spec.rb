require 'rails_helper'

RSpec.describe CartItemsController, type: :controller do
  let(:user) { create(:user, role: :buyer) }
  let(:seller) { create(:user, role: :seller) }
  let(:product) { create(:product, user: seller, quantity: 10, price: 29.99) }
  let(:cart) { create(:cart, user: user) }
  let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1, price: product.price) }

  describe "POST #create" do
    context "when user is signed in" do
      before { sign_in user }

      context "when adding someone else's product" do
        it "creates a new cart item" do
           
          expect {
            post :create, params: { product_id: product.id }
          }.to change(CartItem, :count).by(1)
        end

        it "redirects to the product page with success notice" do
           
          post :create, params: { product_id: product.id }
          expect(response).to redirect_to(product_path(product))
          expect(flash[:notice]).to eq('Product added to cart.')
        end

        context "when product is already in cart" do
          before { cart_item } 

          it "increases the quantity of existing cart item" do
             
            expect {
              post :create, params: { product_id: product.id }
              cart_item.reload
            }.to change(cart_item, :quantity).by(1)
          end
        end
      end

      context "when adding own product" do
        before { sign_in seller }

        it "does not create a cart item" do
           
          expect {
            post :create, params: { product_id: product.id }
          }.not_to change(CartItem, :count)
        end

        it "redirects to product page with alert" do
          
          post :create, params: { product_id: product.id }
          expect(response).to redirect_to(product_path(product))
          expect(flash[:alert]).to eq('You cannot add your own product to cart.')
        end
      end
    end

    context "when user is not signed in" do
      it "creates a cart with session ID" do
         
        expect {
          post :create, params: { product_id: product.id }
        }.to change(Cart, :count).by(1)

        created_cart = Cart.last
        expect(created_cart.session_id).not_to be_nil
        expect(created_cart.user_id).to be_nil
      end

      it "adds product to session cart" do
         
        expect {
          post :create, params: { product_id: product.id }
        }.to change(CartItem, :count).by(1)
      end
    end
  end

  describe "PUT #update" do
    before { sign_in user }

    it "updates the cart item quantity" do
       
      expect {
        put :update, params: { id: cart_item.id, cart_item: { quantity: 3 } }
        cart_item.reload
      }.to change(cart_item, :quantity).from(1).to(3)
    end

    it "redirects to cart path with notice" do
       
      put :update, params: { id: cart_item.id, cart_item: { quantity: 3 } }
      expect(response).to redirect_to(cart_path(user.cart))
      expect(flash[:notice]).to eq('Cart item updated.')
    end
  end

  describe "DELETE #destroy" do
    before do
      sign_in user
      cart_item
    end

    it "removes the cart item" do
       
      expect {
        delete :destroy, params: { id: cart_item.id }
      }.to change(CartItem, :count).by(-1)
    end

    it "redirects to cart path with notice" do
       
      delete :destroy, params: { id: cart_item.id }
      expect(response).to redirect_to(cart_path(user.cart))
      expect(flash[:notice]).to eq('Cart item removed.')
    end
  end

  describe "POST #apply_coupon" do
    before { sign_in user }
    let!(:coupon) { create(:coupon, code: "TEST10", discount: 0.1) }

    context "with valid coupon code" do
      it "applies the coupon to the cart" do
         
        expect {
          post :apply_coupon, params: { coupon_code: "TEST10" }
          cart.reload
        }.to change(cart, :discount_amount).from(0.0).to(0.1)
      end

      it "redirects to cart with success notice" do
         
        post :apply_coupon, params: { coupon_code: "TEST10" }
        expect(response).to redirect_to(cart_path)
        expect(flash[:notice]).to include("Coupon 'TEST10' applied successfully")
      end
    end

    context "with invalid coupon code" do
      it "redirects to cart with alert" do
         
        post :apply_coupon, params: { coupon_code: "INVALID" }
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eq('Invalid coupon code.')
      end
    end
  end
end
