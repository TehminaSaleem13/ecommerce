class ProductCreationWorker
    include Sidekiq::Worker
  
    def perform(user_id)
      user = User.find_by(id: user_id)
  
      unless user
        Rails.logger.error "User with ID #{user_id} not found. Skipping product creation."
        return
      end
  
      product = user.products.create(
        title: "Automated Product - #{SecureRandom.hex(4)}",
        description: "This is an automatically created product.",
        price: rand(10..100),
        quantity: rand(1..10)
      )
  
      if product.persisted?
        Rails.logger.info "Product created for user ##{user.id}: #{product.title}"
      else
        Rails.logger.error "Failed to create product for user ##{user.id}. Errors: #{product.errors.full_messages.join(', ')}"
      end
    end
  end
  