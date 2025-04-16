# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
  
    def stripe
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)
  
      event = nil
  
      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      rescue JSON::ParserError => e
        render json: { error: 'Invalid payload' }, status: 400 and return
      rescue Stripe::SignatureVerificationError => e
        render json: { error: 'Invalid signature' }, status: 400 and return
      end
  
      # Handle the event
      case event.type
      when 'checkout.session.completed'
        session = event.data.object
  
        order = Order.find_by(stripe_session_id: session.id)
        if order
          order.update(status: 'paid')
  
          order.cart_items.each do |item|
            product = item.product
            product.update!(quantity: product.quantity - item.quantity)
          end
        end
      end
  
      render json: { message: 'Received' }
    end
  end
  