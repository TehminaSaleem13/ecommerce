
class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.stripe[:webhook_secret]

    event = nil

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError
     
      head :bad_request
      return
    rescue Stripe::SignatureVerificationError
     
      head :bad_request
      return
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object

    end

    head :ok
  end

 

  
end
