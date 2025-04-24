require 'rails_helper'

RSpec.describe CheckoutController, type: :controller do
  let(:user) { create(:user, role: :buyer) }
  let(:product) { create(:product) }
  let(:cart) { create(:cart, user: user) }
  let(:cart_item) { create(:cart_item, cart: cart, product: product) }
  let(:stripe_session_id) { "cs_test_a1b2c3d4e5f6g7h8" }
  
 
  let(:stripe_session) do
    double("Stripe::Checkout::Session", 
           id: stripe_session_id,
           url: "https://checkout.stripe.com/pay/#{stripe_session_id}",
           client_reference_id: cart.id.to_s)
  end
  
  
  before do
    Rails.application.routes.default_url_options[:host] = 'localhost:3000'
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
          allow(controller).to receive(:current_user).and_return(user)
          allow(user).to receive(:cart).and_return(cart)
          allow(cart).to receive(:cart_items).and_return([])
          allow(cart).to receive(:blank?).and_return(false)
        end
        
        it "redirects to cart with alert message" do
          post :create
          expect(response).to redirect_to(cart_path)
          expect(flash[:alert]).to eq('Your cart is empty.')
        end
      end
      
      context "with items in cart but insufficient inventory" do
        before do
          allow(controller).to receive(:current_user).and_return(user)
          allow(user).to receive(:cart).and_return(cart)
          allow(cart).to receive(:blank?).and_return(false)
          allow(cart).to receive(:cart_items).and_return([cart_item])
          allow(cart_item).to receive(:product).and_return(product)
          allow(product).to receive(:quantity).and_return(0)
          allow(product).to receive(:title).and_return("Test Product")
          allow(cart_item).to receive(:quantity).and_return(1)
        end
        
        it "redirects to cart with inventory alert" do
          post :create
          expect(response).to redirect_to(cart_path)
          expect(flash[:alert]).to include("Insufficient quantity available")
        end
      end
      
      context "with valid cart and sufficient inventory" do
        before do
          allow(controller).to receive(:current_user).and_return(user)
          allow(user).to receive(:cart).and_return(cart)
          allow(cart).to receive(:blank?).and_return(false)
          allow(cart).to receive(:cart_items).and_return([cart_item])
          allow(cart).to receive(:id).and_return(1)
          allow(cart_item).to receive(:product).and_return(product)
          allow(cart_item).to receive(:quantity).and_return(1)
          allow(product).to receive(:quantity).and_return(10)
          allow(product).to receive(:title).and_return("Test Product")
          
         
          stripe_service = double(StripeCheckoutService)
          allow(StripeCheckoutService).to receive(:new).with(cart).and_return(stripe_service)
          allow(stripe_service).to receive(:create_session).and_return(stripe_session)
        end
        
        it "creates Stripe session and redirects to Stripe checkout" do
          post :create
          byebug
          expect(response).to redirect_to(stripe_session.url)
          expect(response.status).to eq(302) 
        end
      end
      
      context "when Stripe service raises an error" do
        before do
          allow(controller).to receive(:current_user).and_return(user)
          allow(user).to receive(:cart).and_return(cart)
          allow(cart).to receive(:blank?).and_return(false)
          allow(cart).to receive(:cart_items).and_return([cart_item])
          allow(cart).to receive(:id).and_return(1)
          allow(cart_item).to receive(:product).and_return(product)
          allow(cart_item).to receive(:quantity).and_return(1)
          allow(product).to receive(:quantity).and_return(10)
          
          stripe_service = double(StripeCheckoutService)
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
      allow(controller).to receive(:current_user).and_return(user)
      allow(user).to receive(:cart).and_return(cart)
      allow(cart).to receive(:id).and_return(1)
    end
    
    context "with valid session" do
      before do
       
        allow(Stripe::Checkout::Session).to receive(:retrieve)
          .with(stripe_session_id)
          .and_return(stripe_session)
      end
      
      it "processes the order successfully" do
        checkout_success_service = double(CheckoutSuccessService)
        order = double(Order, id: 12345)
        
        allow(CheckoutSuccessService).to receive(:new).with(cart).and_return(checkout_success_service)
        allow(checkout_success_service).to receive(:process).and_return(order)
        
        get :success, params: { session_id: stripe_session_id }
        
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to include("Order #12345 has been placed successfully")
      end
      
      it "handles processing errors gracefully" do
        checkout_success_service = double(CheckoutSuccessService)
        
        allow(CheckoutSuccessService).to receive(:new).with(cart).and_return(checkout_success_service)
        allow(checkout_success_service).to receive(:process).and_raise(StandardError.new("Processing failed"))
        
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
