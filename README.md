## Overview
This project consists of three components:
1. A simple page that provides product information and a payment form
2. A Sinatra backend to handle requests and private keys
3. An event logger to log successful payments

This readme assumes that the user is on a Mac (though the sample commands will also run on most linux distros).
If using Windows, use WSL 2 to simulate your preferred flavor of Linux. WSL 2
can be installed via
[PowerShell](https://docs.microsoft.com/en-us/windows/wsl/install-win10) or by
downloading the official [Windows
Terminal](https://www.microsoft.com/en-ca/p/windows-terminal/9n0dx20hk701) app from the Microsoft Store.

## Setup instructions

1. Open a terminal window, navigate to your preferred directory and clone the
   repository from GitHub.

   The examples below assume that you are working from your `Documents` folder.

```bash
cd ~/Documents
git clone https://github.com/meijae/rings-online-shop
```

2. Bundle the required dependencies.

```bash
cd ~/Documents/rings-online-shop/server
bundle install
```

3. Start the local server.

```bash
ruby server.rb -o 127.0.0.1
```

4. Verify the server is running and that the integration is working by loading
   `http://localhost:4242/checkout` in a web browser.
   

## Testing from localhost
5. Test the payment form using Stripe [test cases](https://stripe.com/docs/payments/accept-a-payment#web-test-integration).


## Testing the Webhook
6. Install the Stripe CLI by following the steps in the [Stripe documentation](https://stripe.com/docs/payments/handling-payment-events#install-cli). You will need a Stripe account in order to test using Stripe CLI.

7. If the server has been stopped, restart it using step 3 above.

8. Start the Stripe listener and forward events to the app's server.

```bash
stripe listen --forward-to localhost:4242/webhook
```

9. Open a new terminal window or tab and simulate the below event to test the webhook application.

```bash
stripe trigger payment_intent.succeeded
```

The response can be observed in the terminal window where you started the Stripe listener.

## Viewing the Log
After a successful webhook is triggered, the application will write an entry
into the log file. The log file is saved in `server/checkout_success.log`. You
can open this with any text editor.

# rings-online-shop
