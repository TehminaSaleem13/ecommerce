require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  describe "GET #index" do
    context "when user is not signed in" do
      it "assigns all products to @products" do

        
        out_of_stock_product = create(:product, :out_of_stock)

        get :index

        expect(assigns(:products)).to match_array([out_of_stock_product])
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is signed in as seller" do
      let(:seller) { create(:user, :seller) }

      before do
        sign_in seller
      end

      it "assigns user's products to @your_products and others to @all_products" do
        seller_product = create(:product, user: seller)
        other_product = create(:product)

        get :index

        expect(assigns(:your_products)).to include(seller_product)
        expect(assigns(:all_products)).to include(other_product)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user is signed in but not a seller" do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it "assigns all products to @products" do
        product1 = create(:product)
        product2 = create(:product)

        get :index

        expect(assigns(:products)).to include(product1, product2)
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET #show" do
    it "assigns the requested product to @product" do
      product = create(:product)

      get :show, params: { id: product.id }

      expect(assigns(:product)).to eq(product)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET #new" do
    context "when user is signed in as seller" do
      let(:seller) { create(:user, :seller) }

      before do
        sign_in seller
      end

      it "assigns a new product to @product" do
        get :new

        expect(assigns(:product)).to be_a_new(Product)
        expect(assigns(:product).product_images.size).to eq(1)
      end
    end
  end

  describe "POST #create" do
    context "when user is signed in as seller" do
      let(:seller) { create(:user, :seller) }

      before do
        sign_in seller
      end

      context "with valid params" do
        let(:product_params) { attributes_for(:product) }

        it "creates a new product" do
          expect {
            post :create, params: { product: product_params }
          }.to change(Product, :count).by(1)
        end

        it "redirects to the created product" do
          post :create, params: { product: product_params }
          expect(response).to redirect_to(Product.last)
        end

        it "handles product creation without images" do
          post :create, params: { product: product_params }
          expect(response).to redirect_to(Product.last)
        end
      end

      context "with invalid params" do
        it "re-renders the new template" do
          post :create, params: { product: { title: "" } }
          expect(response).to render_template(:new)
        end
      end
    end
  end

  describe "GET #edit" do
    let(:product) { create(:product) }

    context "when owner is signed in" do
      before do
        sign_in product.user
      end

      it "assigns the requested product to @product" do
        get :edit, params: { id: product.id }
        expect(assigns(:product)).to eq(product)
      end
    end
  end

  describe "PATCH #update" do
    let(:product) { create(:product) }

    context "when owner is signed in" do
      before do
        sign_in product.user
      end

      context "with valid params" do
        it "updates the product and redirects" do
          patch :update, params: { id: product.id, product: { title: "Updated" } }

          expect(response).to redirect_to(product_path(product))
          expect(product.reload.title).to eq("Updated")
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:product) { create(:product) }

    context "when owner is signed in" do
      before do
        sign_in product.user
      end

      it "destroys the product" do
        expect {
          delete :destroy, params: { id: product.id }
        }.to change(Product, :count).by(-1)
      end

      it "redirects to root path" do
        delete :destroy, params: { id: product.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
