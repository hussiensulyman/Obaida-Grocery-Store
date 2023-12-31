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
  });
  