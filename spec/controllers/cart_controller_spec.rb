require 'rails_helper'

RSpec.describe CartsController, type: :controller do
  let(:user) { create(:user) }
  let(:cart) { create(:cart, user: user, session_id: session.id.to_s) }
  let(:product) { create(:product) }
  let(:cart_item) { create(:cart_item, cart: cart, product: product) }

  describe "GET #show" do
    context "when user is signed in" do
      before { sign_in user }

      it "returns a success response" do
        
        get :show
        expect(response).to be_successful
      end

      it "assigns the user's cart as @cart" do
        cart 
        
        get :show
        expect(assigns(:cart)).to eq(cart)
      end

      it "creates a new cart if user doesn't have one" do
        
        expect {
          get :show
        }.to change(Cart, :count).by(1)
      end

      context "when cart needs merging" do
        before do
          session[:cart_needs_merge] = true
          
          @guest_cart = create(:cart, :guest_cart, session_id: session.id.to_s)
          create(:cart_item, cart: @guest_cart, product: product)
        end

        it "merges the session cart with user cart" do
          
          cart_merger = instance_double(CartMerger)
          allow(CartMerger).to receive(:new).with(user, session).and_return(cart_merger)
          expect(cart_merger).to receive(:merge)

          get :show
        end

        it "removes the cart_needs_merge flag from session" do
          
          get :show
          expect(session[:cart_needs_merge]).to be_nil
        end
      end
    end

    context "when user is not signed in" do
      it "returns a success response" do
       
        get :show
        expect(response).to be_successful
      end

      it "creates a session-based cart" do
     
        expect {
          get :show
        }.to change(Cart, :count).by(1)

        created_cart = Cart.last
        expect(created_cart.session_id).not_to be_nil
      end
    end
  end
end
