require 'rails_helper'

RSpec.describe CheckoutController, type: :controller do
  let(:user) { create(:user, role: :buyer) }
  let(:product) { create(:product, quantity: 10) }
  let(:cart) { create(:cart, user: user) }
  let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1, price: product.price) }
  let(:stripe_session_id) { "cs_test_a1b2c3d4e5f6g7h8" }
  let(:stripe_session) do
    double("Stripe::Checkout::Session",
           id: stripe_session_id,
           url: "https://checkout.stripe.com/pay/#{stripe_session_id}",
           client_reference_id: cart.id.to_s,
           amount_total: 2999, 
           currency: 'usd')
  end

  before do
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
    
    cart_item
  end

  describe "#create" do
    context "when user is not signed in" do
      it "redirects to sign in page" do
         
        post :create
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to eq('Please sign in or sign up to proceed with checkout.')
      end
    end

    context "when user is signed in" do
      before do
        sign_in user
      end

      context "with empty cart" do
        before do
          
          cart.cart_items.destroy_all
        end

        it "redirects to cart with alert message" do
           
          post :create
          expect(response).to redirect_to(cart_path)
          expect(flash[:alert]).to eq('Your cart is empty.')
        end
      end

      context "with items in cart but insufficient inventory" do
        before do
          product.update(quantity: 0)
        end

        it "redirects to cart with inventory alert" do
           
          post :create
          expect(response).to redirect_to(cart_path)
          expect(flash[:alert]).to include("Insufficient quantity available")
        end
      end

      context "with valid cart and sufficient inventory" do
        before do
          stripe_service = instance_double(StripeCheckoutService)
          allow(StripeCheckoutService).to receive(:new).with(cart).and_return(stripe_service)
          allow(stripe_service).to receive(:create_session).and_return(stripe_session)
        end

        it "creates Stripe session and redirects to Stripe checkout" do
           
          post :create
          expect(response).to redirect_to(stripe_session.url)
          expect(response.status).to eq(302)
        end
      end

      context "when Stripe service raises an error" do
        before do
          stripe_service = instance_double(StripeCheckoutService)
          allow(StripeCheckoutService).to receive(:new).with(cart).and_return(stripe_service)
          allow(stripe_service).to receive(:create_session).and_raise(StandardError.new("Stripe error"))
        end

        it "handles errors and redirects to cart" do
           
          post :create
          expect(response).to redirect_to(cart_path)
          expect(flash[:alert]).to include("An error occurred while processing your payment")
        end
      end
    end
  end

  describe "#success" do
    before do
      sign_in user
    end

    context "with valid session" do
      before do
        allow(Stripe::Checkout::Session).to receive(:retrieve)
          .with(stripe_session_id)
          .and_return(stripe_session)
      end

      it "processes the order successfully" do
         
        expect {
          get :success, params: { session_id: stripe_session_id }
        }.to change(Order, :count).by(1)

        order = Order.last
        expect(order.user).to eq(user)
        expect(order.total_price).to eq(29.99) 
        expect(order.currency).to eq('usd')
        expect(order.payment_status).to eq('paid')

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to include("Order ##{order.id} has been placed successfully")
      end

      it "handles processing errors gracefully" do
         
        allow_any_instance_of(User).to receive(:orders).and_raise(StandardError.new("Processing failed"))

        get :success, params: { session_id: stripe_session_id }
        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to include("There was a problem processing your order")
      end
    end

    it "handles invalid session" do
       
      get :success, params: { session_id: "" }

      expect(response).to redirect_to(cart_path)
      expect(flash[:alert]).to eq("Invalid checkout session")
    end

    context "with session belonging to another user" do
      before do
        different_session = double("Stripe::Checkout::Session",
          id: "different_id",
          client_reference_id: "999"
        )

        allow(Stripe::Checkout::Session).to receive(:retrieve)
          .with("different_id")
          .and_return(different_session)
      end

      it "rejects the invalid session" do
         
        get :success, params: { session_id: "different_id" }

        expect(response).to redirect_to(cart_path)
        expect(flash[:alert]).to eq("Invalid checkout session")
      end
    end
  end
end
