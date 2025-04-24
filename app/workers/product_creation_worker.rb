class ProductCreationWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find_by(id: user_id)

    unless user
      Rails.logger.error "User with ID #{user_id} not found. Skipping product creation."
      return
    end

    current_time = Time.current.strftime("%Y-%m-%d %H:%M:%S")

    product = user.products.create(
      title: "This is a product created at #{current_time}",
      description: "This is an automatically created product.",
      price: rand(10..100),
      quantity: rand(1..10)
    )

    if product.persisted?
      Rails.logger.info "Product created for user ##{user.id} at #{current_time}: #{product.title}"
    else
      Rails.logger.error "Failed to create product for user ##{user.id} at #{current_time}. Errors: #{product.errors.full_messages.join(', ')}"
    end
  end
end
