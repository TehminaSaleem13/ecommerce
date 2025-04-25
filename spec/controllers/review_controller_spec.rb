require 'rails_helper'

RSpec.describe ReviewsController, type: :controller do
  let(:buyer) { create(:user) }
  let(:seller) { create(:user, :seller) }
  let(:admin) { create(:user, :admin) }
  let(:other_user) { create(:user) }
  let(:product) { create(:product, user: seller) }
  let(:review) { create(:review, user: buyer, product: product) }
  let(:valid_attributes) { { text: "This is a great product!" } }
  

  describe "GET #index" do
    it "returns a success response" do
      
      get :index, params: { product_id: product.id }
      expect(response).to be_successful
    end

    it "assigns all reviews for the product as @reviews" do
      review 
      get :index, params: { product_id: product.id }
      expect(assigns(:reviews)).to eq([review])
    end
  end

  describe "GET #new" do
    context "when user is signed in" do
      before { sign_in buyer }

      it "returns a success response" do
        
        get :new, params: { product_id: product.id }
        expect(response).to be_successful
      end

      it "assigns a new review as @review" do
        get :new, params: { product_id: product.id }
        expect(assigns(:review)).to be_a_new(Review)
      end
    
      
     
    end

   
  end

  describe "POST #create" do
    context "when user is signed in" do
      context "as a buyer" do
        before { sign_in buyer }

        context "with valid params" do
          it "creates a new Review" do
            
            expect {
              post :create, params: { product_id: product.id, review: valid_attributes }
            }.to change(Review, :count).by(1)
          end

          it "assigns the current user to the review" do
            post :create, params: { product_id: product.id, review: valid_attributes }
            expect(assigns(:review).user).to eq(buyer)
          end

          it "redirects to the product page" do
            post :create, params: { product_id: product.id, review: valid_attributes }
            expect(response).to redirect_to(product_path(product))
          end

          it "sets a success notice" do
            post :create, params: { product_id: product.id, review: valid_attributes }
            expect(flash[:notice]).to eq('Review was successfully created.')
          end
        end

      
        
      
      end
      
    
    end

  
  end

  describe "GET #edit" do
    context "when user is signed in" do
      context "as the review owner" do
        before { sign_in buyer }

        it "returns a success response" do
          
          get :edit, params: { product_id: product.id, id: review.id }
          expect(response).to be_successful
        end

        it "assigns the requested review as @review" do
          get :edit, params: { product_id: product.id, id: review.id }
          expect(assigns(:review)).to eq(review)
        end
      end

    
      
    
    end

   
  end

  describe "PUT #update" do
    context "when user is signed in" do
      context "as the review owner" do
        before { sign_in buyer }

        context "with valid params" do
          let(:new_attributes) { { text: "Updated review text" } }

          it "updates the requested review" do
            put :update, params: { product_id: product.id, id: review.id, review: new_attributes }
            review.reload
            expect(review.text).to eq("Updated review text")
          end

          it "redirects to the product page" do
            put :update, params: { product_id: product.id, id: review.id, review: new_attributes }
            expect(response).to redirect_to(product_path(product))
          end

          it "sets a success notice" do
            put :update, params: { product_id: product.id, id: review.id, review: new_attributes }
            expect(flash[:notice]).to eq('Review was successfully updated.')
          end
        end

       
      end

    
      
     
    end

  
  end

  describe "DELETE #destroy" do
    context "when user is signed in" do
      context "as the review owner" do
        before { 
          sign_in buyer
          review 
        }

        it "destroys the requested review" do
          
          expect {
            delete :destroy, params: { product_id: product.id, id: review.id }
          }.to change(Review, :count).by(-1)
        end

        it "redirects to the product page" do
          delete :destroy, params: { product_id: product.id, id: review.id }
          expect(response).to redirect_to(product_path(product))
        end

        it "sets a success notice" do
          delete :destroy, params: { product_id: product.id, id: review.id }
          expect(flash[:notice]).to eq('Review was successfully deleted.')
        end
      end

      
    
    end

    context "when user is not signed in" do
      before { review } # Create the review

      it "redirects to the sign in page" do
        delete :destroy, params: { product_id: product.id, id: review.id }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end