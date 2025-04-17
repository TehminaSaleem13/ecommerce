# app/controllers/stripe_webhooks_controller.rb
class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.stripe[:webhook_secret]

    event = nil

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      Rails.logger.info("Webhook received: #{event.type}")
      Rails.logger.info("Webhook payload: #{payload}")
    rescue JSON::ParserError => e
      # Invalid payload
      Rails.logger.error("Webhook error: Invalid payload")
      head :bad_request
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      Rails.logger.error("Webhook error: Invalid signature")
      head :bad_request
      return
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      handle_checkout_session(session)
    end

    head :ok
  end

  private

  def handle_checkout_session(session)
    Rails.logger.info("Handling checkout session: #{session.id}")
    # No need to update quantities here; it will be handled by the CheckoutController
  end
end
