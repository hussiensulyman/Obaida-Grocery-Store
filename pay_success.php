<?php
session_start();
require_once('vendor/autoload.php');
\Stripe\Stripe::setApiKey('sk_test_51ORNFODJnQque40bnKNuOle4x7OXixQtFSs7R1Lux0J09qcABzzJXURkmSH7KP7wvonGkS5k5xbzdF8HJtudNwMH00KsXzAiVJ'); // Replace with your Stripe secret key

include("connection.php");
error_reporting(0);

if (!isset($_SESSION['customer'])) {
    header("location:index.php");
}

$cust = $_SESSION['customer'];

$paymentIntentId = isset($_GET['payment_intent_id']) ? $_GET['payment_intent_id'] : null;

$paymentDetails = null; // Initialize an empty array for payment details

if ($paymentIntentId) {
    try {
        $paymentIntent = \Stripe\PaymentIntent::retrieve($paymentIntentId);
        // Assuming $paymentIntent contains the response from Stripe
        $paymentDetails = [
            'payment_id' => $paymentIntent->id,
            'purpose' => $paymentIntent->metadata['purpose'],
            'buyer_name' => $paymentIntent->metadata['buyer_name'],
            'buyer_phone' => $paymentIntent->metadata['buyer_phone'],
            'buyer_email' => $paymentIntent->metadata['buyer_email'],
            'status' => $paymentIntent->status,
        ];
    } catch (\Stripe\Exception\ApiErrorException $e) {
        // Handle Stripe API error
        echo 'Stripe Error: ' . $e->getMessage();
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Payment Page</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"></script>
</head>
<body>
<?php
$q2 = "SELECT * FROM customers WHERE email= '$cust'";
$data2 = mysqli_query($conn, $q2);
while ($res2 = mysqli_fetch_assoc($data2)) {
    $address = $res2['street'] . ", " . $res2['city'] . ", " . $res2['pincode'];
}
?>
<div class="container">
    <div class="row justify-content-center">
        <div class="table-resp">
            <h2 class="text-center text-black mb-5" style="margin-top: 20px;"> Payment Details </h2>
            <table class="table table-bordered" style="margin-top: 40px;">
                <?php if ($paymentDetails): ?>
                    <tr>
                        <th>Payment ID</th>
                        <td><?= htmlspecialchars($paymentDetails['payment_id']); ?></td>
                    </tr>
                    <tr>
                        <th>Purchased from</th>
                        <td><?= $paymentDetails['purpose']; ?></td>
                    </tr>
                    <tr>
                        <th>Buyer Name</th>
                        <td><?= $paymentDetails['buyer_name']; ?></td>
                    </tr>
                    <tr>
                        <th>Buyer Phone No.</th>
                        <td><?= $paymentDetails['buyer_phone']; ?></td>
                    </tr>
                    <tr>
                        <th>Buyer Email</th>
                        <td><?= $paymentDetails['buyer_email']; ?></td>
                    </tr>
                    <tr>
                        <th>Payment Status</th>
                        <td><?= $paymentDetails['status']; ?></td>
                    </tr>
                    <!-- You can add more payment details here as needed -->
                <?php endif; ?>
                <tr>
                    <th>Buyer Address</th>
                    <td><?= $address; ?></td>
                </tr>
                <tr>
                    <th>Order Date</th>
                    <td>
                        <?php
                        date_default_timezone_set('Asia/Kolkata');
                        $date = date('d/m/Y H:i:s', time());
                        echo $date;
                        ?>
                    </td>
                </tr>
            </table>
            <div class="text-center mt-4">
                <a href="index.php" class="btn btn-primary">Home Page</a>
            </div>

<?php
require './phpmailer/PHPMailerAutoload.php';

function send_email($vendor, $item, $qty, $pay_id, $sbuyer_name, $sbuyer_phone, $address){
$mail = new PHPMailer;

$htmlversion= "You have received and order <br> Product: <b>".$item."</b> <br> Qty: <b>".$qty."</b> <br> Order ID: <b>".$pay_id."</b> <br> Customer Name: <b>".$sbuyer_name."</b> <br> Customer Phone No: <b>".$sbuyer_phone."</b> <br> Customer Address <b>".$address."</b>";
$textversion= 'Order Received';

//$mail->SMTPDebug = 3;                               // Enable verbose debug output

$mail->isSMTP();                                      // Set mailer to use SMTP
$mail->Host = 'smtp.gmail.com';  // Specify main and backup SMTP servers
$mail->SMTPAuth = true;                               // Enable SMTP authentication
$mail->Username = 'rfidlibrarypccoe@gmail.com';                 // SMTP username
$mail->Password = '14785269';                           // SMTP password
$mail->SMTPSecure = 'tls';                            // Enable TLS encryption, `ssl` also accepted
$mail->Port = 587;                                    // TCP port to connect to

$mail->setFrom('rfidlibrarypccoe@gmail.com', 'Obaida Grocery Store');
$mail->addAddress($vendor);               // Name is optional

$mail->isHTML(true);

$mail->Subject = 'Order Received';
$mail->Body    = $htmlversion;
$mail->AltBody = $textversion;

if(!$mail->send()) {
    echo 'Message could not be sent.';
    echo 'Mailer Error: ' . $mail->ErrorInfo;
} else {
    /*echo 'Message has been sent';*/
}
}

function send_email_customer($cust, $item, $qty, $pay_id, $svendor_name, $svendor_phone, $svendor_address){
$mail = new PHPMailer;

$htmlversion= "You have ordered for <br> Product: <b>".$item."</b> <br> Qty: <b>".$qty."</b> <br> Order ID: <b>".$pay_id."</b> <br> Vendor Name: <b>".$svendor_name."</b> <br> Vendor Phone No: <b>".$svendor_phone."</b> <br> Vendor Address <b>".$svendor_address."</b>";
$textversion= 'Order Successful';

//$mail->SMTPDebug = 3;                               // Enable verbose debug output

$mail->isSMTP();                                      // Set mailer to use SMTP
$mail->Host = 'smtp.gmail.com';  // Specify main and backup SMTP servers
$mail->SMTPAuth = true;                               // Enable SMTP authentication
$mail->Username = 'rfidlibrarypccoe@gmail.com';                 // SMTP username
$mail->Password = '14785269';                           // SMTP password
$mail->SMTPSecure = 'tls';                            // Enable TLS encryption, `ssl` also accepted
$mail->Port = 587;                                    // TCP port to connect to

$mail->setFrom('rfidlibrarypccoe@gmail.com', 'Obaida Grocery Store');
$mail->addAddress($cust);               // Name is optional

$mail->isHTML(true);

$mail->Subject = 'Order Successful';
$mail->Body    = $htmlversion;
$mail->AltBody = $textversion;

if(!$mail->send()) {
    echo 'Message could not be sent.';
    echo 'Mailer Error: ' . $mail->ErrorInfo;
} else {
    /*echo 'Message has been sent';*/
}
}


function send_email_admin($item, $qty, $pay_id, $svendor_name, $svendor_phone, $svendor_address, $sbuyer_name, $sbuyer_phone, $address){
$mail = new PHPMailer;

$htmlversion= "Order Details <br> Product: <b>".$item."</b> <br> Qty: <b>".$qty."</b> <br> Order ID: <b>".$pay_id."</b> <br> Vendor Name: <b>".$svendor_name."</b> <br> Vendor Phone No: <b>".$svendor_phone."</b> <br> Vendor Address <b>".$svendor_address."</b> <br> Customer Name: <b>".$sbuyer_name."</b> <br> Customer Phone No: <b>".$sbuyer_phone."</b> <br> Customer Address <b>".$address."</b>";
$textversion= 'Order Successful';

//$mail->SMTPDebug = 3;                               // Enable verbose debug output

$mail->isSMTP();                                      // Set mailer to use SMTP
$mail->Host = 'smtp.gmail.com';  // Specify main and backup SMTP servers
$mail->SMTPAuth = true;                               // Enable SMTP authentication
$mail->Username = 'rfidlibrarypccoe@gmail.com';                 // SMTP username
$mail->Password = '14785269';                           // SMTP password
$mail->SMTPSecure = 'tls';                            // Enable TLS encryption, `ssl` also accepted
$mail->Port = 587;                                    // TCP port to connect to

$mail->setFrom('rfidlibrarypccoe@gmail.com', 'Obaida Grocery Store');
$mail->addAddress('gokhalehemal11@gmail.com');               // Name is optional

$mail->isHTML(true);

$mail->Subject = 'Order Details';
$mail->Body    = $htmlversion;
$mail->AltBody = $textversion;

if(!$mail->send()) {
    echo 'Message could not be sent.';
    echo 'Mailer Error: ' . $mail->ErrorInfo;
} else {
    /*echo 'Message has been sent';*/
}
}
?>
					<div class="text-center text-danger mb-2">
						<button name="order" class="btn btn-danger" onclick='window.location.href = "http://localhost/big_store/web/order.php"'>Track your Order</button>
						<button name="shopping" class="btn btn-success" onclick='window.location.href = "http://localhost/big_store/web/index.php"'>Continue Shoppping</button>
					</div>

					<?php
					$spay_id= $response['payments'][0]['payment_id'];
					$sbuyer_name= $response['payments'][0]['buyer_name'];
					$sbuyer_email= $response['payments'][0]['buyer_email'];
					$sbuyer_phone= $response['payments'][0]['buyer_phone'];
					$sstatus= $response['payments'][0]['status'];

					if($response['payments'][0]['status'] == "Credit"){

						$allvalues= $_SESSION['kela'];
						$delivery= $_SESSION['del'];

						if($delivery ==1 )
						{
							$shipping= "Normal";
						}
						else{
							$shipping= "Express";
						}

/*						$sent= array();
						$vendors= array();
						$names= array();
						$qtys= array();*/

						$some= json_decode($allvalues);
						$items = array();
						foreach($some as $arr) {
		    				foreach($arr as $key => $value) {
		        				$items[$key] = $value;
		    				}
		    				$sid= $items['id'];
		    				$stitle= $items['name']; 
		    				$sprice= $items['price'];  
		    				$sqty= $items['quantity']; 
		    				$simage= $items['image'];
		    				$svendor='';

		    				$q2= "SELECT * FROM products WHERE product_id= $sid ";
							$data2= mysqli_query($conn, $q2);

							while($res2= mysqli_fetch_assoc($data2)){
								 $svendor= $res2['vendor_name'];
								 $q3= "SELECT * FROM vendors WHERE email= '$svendor' ";
								 $data3= mysqli_query($conn, $q3);
								 while($res3= mysqli_fetch_assoc($data3)){
								 	$svendor_name= $res3['username'];
								 	$svendor_address= $res3['street'].", ".$res3['city'].", ".$res3['pincode'];
								 	$svendor_phone= $res3['phone'];
								 }
							}

							$q3= "INSERT INTO `orders`(`product_title`, `product_price`, `product_qty`, `product_image`, `vendor_name`, `payment_id`, `payment_status`, `buyer_email`, `buyer_phone`, `buyer_name`, `order_date`,`delivery_status`,`shipping_method`,`buyer_address`) VALUES ('$stitle', '$sprice', '$sqty', '$simage', '$svendor', '$spay_id', '$sstatus', '$sbuyer_email', '$sbuyer_phone', '$sbuyer_name', '$date','ND','$shipping','$address')";
							if(mysqli_query($conn, $q3)){
								send_email($svendor, $stitle, $sqty, $spay_id, $sbuyer_name, $sbuyer_phone, $address);
								send_email_customer($cust, $stitle, $sqty, $spay_id, $svendor_name, $svendor_phone, $svendor_address);
								send_email_admin($stitle, $sqty, $spay_id, $svendor_name, $svendor_phone, $svendor_address, $sbuyer_name, $sbuyer_phone, $address);
							}else {
							    echo "Error: " . $q3 . "<br>" . mysqli_error($conn);
							}


		    				/*array_push($sent, $items['id']);
		    				array_push($names, $items['name']);
		    				array_push($qtys, $items['quantity']);*/
						}
						/*foreach ($sent as $key => $value) {
							$q2= "SELECT * FROM products WHERE product_id= $value ";
							$data2= mysqli_query($conn, $q2);

							while($res2= mysqli_fetch_assoc($data2)){
								array_push($vendors, $res2['vendor_name']);
							}
						}*/
						/*print_r($vendors);
						echo "<br />";
						print_r($names);
						echo "<br />";
						print_r($qtys);*/
					}
				?>
			</div>
		</div>
	</div>

</body>
</html>
