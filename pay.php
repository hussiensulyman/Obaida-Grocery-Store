<?php
session_start();
require_once('vendor/autoload.php');

\Stripe\Stripe::setApiKey('sk_test_51ORNFODJnQque40bnKNuOle4x7OXixQtFSs7R1Lux0J09qcABzzJXURkmSH7KP7wvonGkS5k5xbzdF8HJtudNwMH00KsXzAiVJ');

// Function to handle errors and return a JSON response
function returnError($message) {
    echo json_encode(['error' => $message]);
    exit;
}

// Check for necessary POST data
if (!isset($_POST['cust_name']) || !isset($_POST['total_price']) || !isset($_POST['delivery']) || !isset($_POST['pay_type'])) {
    returnError('Missing required fields');
}

$cust_name = $_POST['cust_name'];
$total = $_POST['total_price'];
$delivery = $_POST['delivery'];
$pay_type = $_POST['pay_type'];

// Assuming $allvalues is a JSON string from the session
$allvalues = $_SESSION['kela'] ?? '[]';
$some = json_decode($allvalues, true);
$items = [];
foreach ($some as $arr) {
    foreach ($arr as $key => $value) {
        $items[$key] = $value;
    }
}

// Calculate total amount with delivery charges
if ($delivery == 1) {
    $total += 50;
} elseif ($delivery == 2) {
    $total += 150;
}

$_SESSION['del'] = $delivery;

// Check payment type (assuming 1 is for Stripe/card payment)
if ($pay_type == 1) {
    try {
        // Create a payment intent with Stripe
        $paymentIntent = \Stripe\PaymentIntent::create([
            'amount' => $total * 100, // Convert to cents
            'currency' => 'EGP',
            'payment_method_types' => ['card'],
            'metadata' => [
                'purpose' => 'Your purpose here', // Set your purpose here
                'buyer_name' => $cust_name,
                'buyer_phone' => 'Buyer Phone', // Set buyer's phone here
                'buyer_email' => 'Buyer Email', // Set buyer's email here
            ],
        ]);

        // Store payment details in session
        $_SESSION['payment_details'] = [
            'payment_id' => $paymentIntent->id,
            'purpose' => $paymentIntent->metadata['purpose'],
            'buyer_name' => $paymentIntent->metadata['buyer_name'],
            'buyer_phone' => $paymentIntent->metadata['buyer_phone'],
            'buyer_email' => $paymentIntent->metadata['buyer_email'],
            'status' => $paymentIntent->status,
            // Add more payment details here as needed
        ];

        // Send client secret and total amount to the client
    } catch (\Stripe\Exception\ApiErrorException $e) {
        returnError('Stripe Error: ' . $e->getMessage());
    }
} else {
    // Handle other payment types or redirect
    header("Location: pay_success.php");
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Payment Form</title>
<!-- Add your CSS file link here -->
<link rel="stylesheet" href="css/payment-form.css">
<style>
  .payment-container {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    height: 85vh; /* This makes the container take up the full viewport height */
  }
</style>
</head>
<body>
<div class="payment-container">
  <header class="payment-header">
    <h1>Obaida Grocery Store</h1>
    <p class="payment-due">Due: <span id="due-date"></span></p>
  </header>
  
  <form action="pay_success.php" method="post" id="payment-form">
    <div class="payment-details">
      <div class="amount-box">
        <span class="amount-title" id="order-amount">$0.00</span>
      </div>
    </div>
    
    <div class="payment-method">
      <p> Thank you for shopping with us!</p> 
      <p>Please review your order summary below.</p>
      
      <div id="card-element">
        <!-- A Stripe Element will be inserted here. -->
      </div>
      
      <div id="card-errors" role="alert"></div>
      
      <button class="btn-pay" type="submit" id="pay-button">Pay Now</button>
    </div>
  </form>
</div>

<footer class="payment-footer">
  <p>Powered by <a href="https://stripe.com">Stripe</a></p>
  <div class="footer-links">
    <a href="#">Terms</a>
    <a href="#">Privacy</a>
  </div>
</footer>

<!-- Stripe JS library -->
<script src="https://js.stripe.com/v3/"></script>
<!-- Your JavaScript file for Stripe -->
<script>
// Assuming you have already included the Stripe.js library in your HTML

document.addEventListener('DOMContentLoaded', function() {
  // Your Stripe public key
  var stripe = Stripe('pk_test_51ORNFODJnQque40bRCc3b51W4tqBP5tU5bP9IA3WhPoRuvEw5ZLZc3wjiXhwvkQU8crawVdzBXtxYycUdpYDqBPV00fQSsLK2g');
  var elements = stripe.elements();

  // Custom styling can be passed to options when creating an Element.
  var style = {
    base: {
      fontSize: '16px',
      color: '#32325d',
    },
  };

  // Create an instance of the card Element.
  var card = elements.create('card', {style: style});

  // Add an instance of the card Element into the `card-element` div.
  card.mount('#card-element');

  // Handle real-time validation errors from the card Element.
  card.on('change', function(event) {
    var displayError = document.getElementById('card-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  });

  // Handle form submission.
  var form = document.getElementById('payment-form');
  form.addEventListener('submit', function(event) {
    event.preventDefault();

    stripe.createToken(card).then(function(result) {
      if (result.error) {
        // Inform the user if there was an error.
        var errorElement = document.getElementById('card-errors');
        errorElement.textContent = result.error.message;
      } else {
        // Send the token to your server.
        stripeTokenHandler(result.token);
      }
    });
  });

  // Submit the form with the token ID.
  function stripeTokenHandler(token) {
    // Insert the token ID into the form so it gets submitted to the server
    var form = document.getElementById('payment-form');
    var hiddenInput = document.createElement('input');
    hiddenInput.setAttribute('type', 'hidden');
    hiddenInput.setAttribute('name', 'stripeToken');
    hiddenInput.setAttribute('value', token.id);
    form.appendChild(hiddenInput);

    // Submit the form
    form.submit();
  }

  // Get the total amount from the JSON response
  var totalAmountInput = <?php echo json_encode($total); ?>;
  
  // Update the order amount and pay button text
  document.getElementById('order-amount').textContent = 'EGP ' + totalAmountInput;
  document.getElementById('pay-button').textContent = 'Pay EGP ' + totalAmountInput;
});
</script>
</body>
</html>
