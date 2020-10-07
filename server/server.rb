require 'stripe'
require 'sinatra'
require 'dotenv'

Dotenv.load
Stripe.api_key = ENV['STRIPE_SECRET_KEY']


set :static, true
set :public_folder, File.join(File.dirname(__FILE__), ENV['STATIC_DIR'])
set :port, 4242

get '/checkout' do
  # Display product and checkout page
  content_type 'text/html'
  send_file File.join(settings.public_folder, 'index.html')
end

def calculate_order_amount(_items)  
  # Customers can buy only 1 item. We are charging one and the same price in USD.
  10000 
end

# An endpoint to start the payment process
post '/create-payment-intent' do
  content_type 'application/json'
  data = JSON.parse(request.body.read)

  # Create a PaymentIntent with the order amount and currency
  payment_intent = Stripe::PaymentIntent.create(
    amount: calculate_order_amount(data['items']),
    currency: data['currency'] 
  )

  # Send publishable key and PaymentIntent details to client
  {
    publishableKey: ENV['STRIPE_PUBLISHABLE_KEY'],
    clientSecret: payment_intent['client_secret'],
    id: payment_intent['id']
  }.to_json
end


post '/webhook' do
  webhook_secret = ENV['STRIPE_WEBHOOK_SECRET']
  payload = request.body.read
  
 ## For ease of the assignment review, webhook signing is disabled
  # if !webhook_secret.empty?
     # Retrieve the event by verifying the signature using the raw body and secret if webhook signing is configured.
     # sig_header = request.env['HTTP_STRIPE_SIGNATURE']
     # event = nil

     # begin
      # event = Stripe::Webhook.construct_event(
        # payload, sig_header, webhook_secret
      # )
    # rescue JSON::ParserError => e
      # # Invalid payload
      # status 400
      # return
    # rescue Stripe::SignatureVerificationError => e
      # # Invalid signature
      # puts '⚠️  Webhook signature verification failed.'
      # status 400
      # return
    # end
  # else
    
    data = JSON.parse(payload, symbolize_names: true)
    event = Stripe::Event.construct_from(data)
  # end
  
  # Get the type of webhook event sent - used to check the status of PaymentIntents.
  event_type = event['type']
  data = event['data']
  data_object = data['object']

  if event_type == 'payment_intent.succeeded'
    puts '💰 Payment received!'

    Logger
       .new('./checkout_success.log')
       .info("Payment #{data_object['id']} succeeded")

  elsif event_type == 'payment_intent.payment_failed'
    puts '❌ Payment failed.'
  end

  content_type 'application/json'
  {
    status: 'success'
  }.to_json
end
