-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 02, 2024 at 03:32 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `grocery`
--

-- --------------------------------------------------------

--
-- Table structure for table `brands`
--

CREATE TABLE `brands` (
  `brand_id` int(100) NOT NULL,
  `brand_title` text NOT NULL,
  `vendor_name` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `brands`
--

INSERT INTO `brands` (`brand_id`, `brand_title`, `vendor_name`) VALUES
(12, 'Nestle', 'Obaida-Grocery@gmail.com'),
(13, 'Other', 'Obaida-Grocery@gmail.com'),
(14, 'kitchen', 'Obaida-Grocery@gmail.com'),
(15, 'household', 'Obaida-Grocery@gmail.com'),
(16, 'personal care', 'Obaida-Grocery@gmail.com'),
(17, 'bakery, eggs and meat', 'Obaida-Grocery@gmail.com'),
(18, 'snacks', 'Obaida-Grocery@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `id` int(10) NOT NULL,
  `p_id` int(10) NOT NULL,
  `ip_add` varchar(250) NOT NULL,
  `user_id` int(10) DEFAULT NULL,
  `qty` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `cat_id` int(100) NOT NULL,
  `cat_title` text NOT NULL,
  `vendor_name` text NOT NULL,
  `cat_name` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`cat_id`, `cat_title`, `vendor_name`, `cat_name`) VALUES
(15, 'water and beverages', 'Obaida-Grocery@gmail.com', 'water_and_beverages'),
(16, 'fruits and vegetables', 'Obaida-Grocery@gmail.com', 'fruits_and_vegetables'),
(17, 'staples', 'Obaida-Grocery@gmail.com', 'staples'),
(18, 'branded food', 'Obaida-Grocery@gmail.com', 'branded_food'),
(19, 'breakfast and cereal', 'Obaida-Grocery@gmail.com', 'breakfast_and_cereal'),
(20, 'snacks', 'Obaida-Grocery@gmail.com', 'snacks'),
(21, 'spices', 'Obaida-Grocery@gmail.com', 'spices'),
(22, 'sweets', 'Obaida-Grocery@gmail.com', 'sweets'),
(23, 'pickle and condiment', 'Obaida-Grocery@gmail.com', 'pickle_and_condiment'),
(24, 'instant food', 'Obaida-Grocery@gmail.com', 'instant_food'),
(25, 'dryfruit', 'Obaida-Grocery@gmail.com', 'dryfruit'),
(27, 'ayurvedic', 'Obaida-Grocery@gmail.com', 'ayurvedic'),
(28, 'babycare', 'Obaida-Grocery@gmail.com', 'babycare'),
(29, 'cosmetics', 'Obaida-Grocery@gmail.com', 'cosmetics'),
(30, 'deo and perfumes', 'Obaida-Grocery@gmail.com', 'deo_and_perfumes'),
(31, 'haircare', 'Obaida-Grocery@gmail.com', 'haircare'),
(32, 'oralcare', 'Obaida-Grocery@gmail.com', 'oralcare'),
(33, 'personal hygiene', 'Obaida-Grocery@gmail.com', 'personal_hygiene'),
(34, 'skincare', 'Obaida-Grocery@gmail.com', 'skincare'),
(35, 'fashion accessories', 'Obaida-Grocery@gmail.com', 'fashion_accessories'),
(36, 'grooming tools', 'Obaida-Grocery@gmail.com', 'grooming_tools'),
(37, 'shaving needs', 'Obaida-Grocery@gmail.com', 'shaving_needs'),
(38, 'sanitary needs', 'Obaida-Grocery@gmail.com', 'sanitary_needs'),
(39, 'noodles and pasta', 'Obaida-Grocery@gmail.com', 'noodles_and_pasta'),
(41, 'biscuit and cookies', 'Obaida-Grocery@gmail.com', 'biscuit_and_cookies'),
(42, 'sauces and ketchups', 'Obaida-Grocery@gmail.com', 'sauces_and_ketchups'),
(43, 'chocolates and candies', 'Obaida-Grocery@gmail.com', 'chocolates_and_candies'),
(44, 'frozen veggies', 'Obaida-Grocery@gmail.com', 'frozen_veggies'),
(45, 'snacks and namkeen', 'Obaida-Grocery@gmail.com', 'snacks_and_namkeen'),
(46, 'indian mithai', 'Obaida-Grocery@gmail.com', 'indian_mithai'),
(47, 'breads and buns', 'Obaida-Grocery@gmail.com', 'breads_and_buns'),
(48, 'dairy', 'Obaida-Grocery@gmail.com', 'dairy'),
(49, 'cakes and pastries', 'Obaida-Grocery@gmail.com', 'cakes_and_pastries'),
(50, 'rusk and khari', 'Obaida-Grocery@gmail.com', 'rusk_and_khari'),
(51, 'eggs', 'Obaida-Grocery@gmail.com', 'eggs'),
(52, 'poultry', 'Obaida-Grocery@gmail.com', 'poultry'),
(53, 'mutton and lamb', 'Obaida-Grocery@gmail.com', 'mutton_and_lamb'),
(54, 'fish and seafood', 'Obaida-Grocery@gmail.com', 'fish_and_seafood'),
(55, 'pork and others', 'Obaida-Grocery@gmail.com', 'pork_and_others'),
(56, 'icecream', 'Obaida-Grocery@gmail.com', 'icecream'),
(57, 'cleaning accessories', 'Obaida-Grocery@gmail.com', 'cleaning_accessories'),
(58, 'cookwear', 'Obaida-Grocery@gmail.com', 'cookwear'),
(59, 'detergents', 'Obaida-Grocery@gmail.com', 'detergents'),
(60, 'gardening', 'Obaida-Grocery@gmail.com', 'gardening'),
(61, 'kitchen and dining', 'Obaida-Grocery@gmail.com', 'kitchen_and_dining'),
(62, 'kitchenwear', 'Obaida-Grocery@gmail.com', 'kitchenwear'),
(63, 'petcare', 'Obaida-Grocery@gmail.com', 'petcare'),
(64, 'plasticwear', 'Obaida-Grocery@gmail.com', 'plasticwear'),
(65, 'pooja needs', 'Obaida-Grocery@gmail.com', 'pooja_needs'),
(66, 'safety accessories', 'Obaida-Grocery@gmail.com', 'safety_accessories'),
(67, 'festive decoratives', 'Obaida-Grocery@gmail.com', 'festive_decoratives'),
(68, 'toys and gifts', 'Obaida-Grocery@gmail.com', 'toys_and_gifts');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` int(6) UNSIGNED NOT NULL,
  `username` varchar(30) DEFAULT NULL,
  `email` varchar(30) DEFAULT NULL,
  `street` varchar(30) DEFAULT NULL,
  `city` varchar(30) DEFAULT NULL,
  `pincode` varchar(30) DEFAULT NULL,
  `password` varchar(50) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `username`, `email`, `street`, `city`, `pincode`, `password`, `phone`) VALUES
(1, 'hemal', 'hemal@gmail.com', 'D6', 'chinchwad', '411019', 'hemal123', '9518786014'),
(2, 'Chinmayee', 'rfidlibrarypccoe@gmail.com', 'Karvenagar', 'Pune', '411001', 'c123', '1234567890'),
(3, 'shubham', 'gokhalehemal11@gmail.com', 'Pote Corner', 'Chinchwad', '411019', 'shubham123', '123457890'),
(4, 'test', 'test@test.com', '123', 'test', 'test', '123', '123');

-- --------------------------------------------------------

--
-- Table structure for table `delivery`
--

CREATE TABLE `delivery` (
  `id` int(6) UNSIGNED NOT NULL,
  `username` varchar(30) DEFAULT NULL,
  `email` varchar(30) DEFAULT NULL,
  `street` varchar(30) DEFAULT NULL,
  `city` varchar(30) DEFAULT NULL,
  `pincode` varchar(30) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `delivery`
--

INSERT INTO `delivery` (`id`, `username`, `email`, `street`, `city`, `pincode`, `phone`) VALUES
(1, 'delivery_boy', 'gokhalehemal11@gmail.com', 'hdfc', 'pune', '411019', '1234567890'),
(2, 'delivery_boy_2', 'gokhalehemal11@gmail.com', 'kakde park', 'pune', '411014', '122111112'),
(95, 'delivery_boy_3', 'something@gmail.com', 'some_street', 'some city', '411019', '01234567890');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(100) NOT NULL,
  `product_title` varchar(255) DEFAULT NULL,
  `product_price` int(100) DEFAULT NULL,
  `product_qty` int(100) DEFAULT NULL,
  `product_image` text DEFAULT NULL,
  `vendor_name` text DEFAULT NULL,
  `payment_id` text DEFAULT NULL,
  `payment_status` text DEFAULT NULL,
  `buyer_email` text DEFAULT NULL,
  `buyer_phone` text DEFAULT NULL,
  `buyer_name` text DEFAULT NULL,
  `order_date` varchar(250) DEFAULT NULL,
  `delivery_status` text DEFAULT NULL,
  `shipping_method` varchar(250) DEFAULT NULL,
  `buyer_address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `product_title`, `product_price`, `product_qty`, `product_image`, `vendor_name`, `payment_id`, `payment_status`, `buyer_email`, `buyer_phone`, `buyer_name`, `order_date`, `delivery_status`, `shipping_method`, `buyer_address`) VALUES
(1, 'Sunflower Oil (5Kg)', 100, 1, 'images/1560280713_of1.png', 'gokhalehemal11@gmail.com', 'MOJO9615E05N07860470', 'Credit', 'gokhalehemal11@gmail.com', '1234567890', 'Shubham', '17/06/2019 09:31:21', 'Returned', 'Normal', NULL),
(2, 'Kabuli Chana (1Kg)', 45, 2, 'images/1560280766_of2.png', 'gokhalehemal11@gmail.com', 'MOJO9615E05N07860470', 'Credit', 'gokhalehemal11@gmail.com', '1234567890', 'Shubham', '17/06/2019 09:31:21', 'ND', 'Normal', NULL),
(3, 'Clips (10 pc)', 20, 1, 'images/1560342587_of20.png', 'gokhalehemal11@gmail.com', 'MOJO9615E05N07860470', 'Credit', 'gokhalehemal11@gmail.com', '1234567890', 'Shubham', '17/06/2019 09:31:21', 'Returned', 'Normal', NULL),
(4, 'Apples (1 kg)', 100, 1, 'images/1560323747_of11.png', 'hemal@gmail.com', 'MOJO9615805N07860780', 'Credit', 'gokhalehemal11@gmail.com', '1234567890', 'Hemal', '17/06/2019 09:31:21', 'Returned', 'Normal', NULL),
(5, 'Banana (6 pcs)', 20, 1, 'images/1560323604_of8.png', 'hemal@gmail.com', 'MOJO9615805N07860780', 'Credit', 'gokhalehemal11@gmail.com', '1234567890', 'Hemal', '17/06/2019 09:31:21', 'Returned', 'Normal', NULL),
(6, 'Lady Finger (250 g)', 20, 2, 'images/1560343032_of17.png', 'hemal@gmail.com', 'MOJO9615805N07860780', 'Credit', 'gokhalehemal11@gmail.com', '1234567890', 'Hemal', '17/06/2019 09:31:21', 'delivery_boy', 'Normal', NULL),
(11, 'Kabuli Chana (1Kg)', 45, 1, 'images/1560280766_of2.png', 'hemal@gmail.com', 'COD740137615', 'Cod', 'gokhalehemal11@gmail.com', '123457890', 'shubham', '17/06/2019 09:31:21', 'delivery_boy_3', 'Normal', NULL),
(16, 'Hair Gel (250 g)', 60, 1, 'images/1560342839_of23.png', 'hemal@gmail.com', 'COD506689832', 'Cod', 'gokhalehemal11@gmail.com', '123457890', 'shubham', '17/06/2019 09:31:21', 'Returned', 'Normal', NULL),
(17, 'Conditioner (200 g)', 55, 1, 'images/1560342648_of21.png', 'hemal@gmail.com', 'COD506689832', 'Cod', 'gokhalehemal11@gmail.com', '123457890', 'shubham', '17/06/2019 09:31:21', 'delivery_boy', 'Normal', NULL),
(19, 'Cleaner (500 g)', 70, 1, 'images/1560342712_of22.png', 'hemal@gmail.com', 'MOJO9617J05N20123237', 'Credit', 'gokhalehemal11@gmail.com', '1234567678', 'hemal', '17/06/2019 10:00:12', 'Returned', 'Normal', NULL),
(20, 'Apples (1 kg)', 100, 1, 'images/1560323747_of11.png', 'gokhalehemal11@gmail.com', 'COD290738570', 'Cod', 'gokhalehemal11@gmail.com', '123457890', 'shubham', '17/06/2019 10:00:49', 'ND', 'Express', NULL),
(21, 'Ribbon (1 pc)', 15, 1, 'images/1560342521_of18.png', 'hemal@gmail.com', 'COD965095464', 'Cod', 'gokhalehemal11@gmail.com', '123457890', 'shubham', '18/06/2019 00:07:49', 'Returned', 'Express', NULL),
(33, 'Sunflower Oil (5Kg)', 100, 1, 'images/1560280713_of1.png', 'gokhalehemal11@gmail.com', 'MOJO9619405N22393813', 'Credit', 'gokhalehemal11@gmail.com', '1234567890', 'Hemal', '19/06/2019 11:10:36', 'Returned', 'Normal', 'Pote Corner, Chinchwad, 411019'),
(34, 'Sunflower Oil (5Kg)', 100, 1, 'images/1560280713_of1.png', 'gokhalehemal11@gmail.com', 'COD140650200', 'Cod', 'gokhalehemal11@gmail.com', '123457890', 'shubham', '20/06/2019 18:43:04', 'delivery_boy', 'Express', 'Pote Corner, Chinchwad, 411019'),
(35, 'Soya Chunks (1Kg)', 55, 1, 'images/1560280805_of3.png', 'hemal@gmail.com', 'COD140650200', 'Cod', 'gokhalehemal11@gmail.com', '123457890', 'shubham', '20/06/2019 18:43:04', 'delivery_boy', 'Express', 'Pote Corner, Chinchwad, 411019'),
(36, 'Hair Gel (250 g)', 60, 1, 'images/1560342839_of23.png', 'hemal@gmail.com', 'MOJO9620V05N80165183', 'Credit', 'gokhalehemal11@gmail.com', '1234567889', 'Shubham', '20/06/2019 18:49:27', 'ND', 'Normal', 'Pote Corner, Chinchwad, 411019'),
(37, 'Moong Dal (200g)', 20, 1, 'images/1560272048_of.png', 'hemal@gmail.com', 'COD760991559', 'Cod', 'gokhalehemal11@gmail.com', '123457890', 'shubham', '20/06/2019 18:57:05', 'delivery_boy_3', 'Normal', 'Pote Corner, Chinchwad, 411019'),
(38, 'Lady Finger (250 g)', 20, 2, 'images/1560343032_of17.png', 'gokhalehemal11@gmail.com', 'COD760991559', 'Cod', 'gokhalehemal11@gmail.com', '123457890', 'shubham', '20/06/2019 18:57:05', 'delivery_boy', 'Normal', 'Pote Corner, Chinchwad, 411019');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(100) NOT NULL,
  `product_cat` int(11) NOT NULL,
  `product_brand` int(100) NOT NULL,
  `product_title` varchar(255) NOT NULL,
  `product_price` int(100) NOT NULL,
  `product_qty` int(11) NOT NULL,
  `product_desc` text NOT NULL,
  `product_image` text NOT NULL,
  `vendor_name` text DEFAULT NULL,
  `isEgyptian` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `product_cat`, `product_brand`, `product_title`, `product_price`, `product_qty`, `product_desc`, `product_image`, `vendor_name`, `isEgyptian`) VALUES
(2, 17, 14, 'Moong Dal (200g)', 20, 5, 'Fresh and healthy Moong Dal', '1560272048_of.png', 'hemal@gmail.com', 1),
(3, 17, 14, 'Sunflower Oil (5Kg)', 100, 10, 'Fresh Sunflower Oil', '1560280713_of1.png', 'gokhalehemal11@gmail.com', 1),
(4, 17, 14, 'Kabuli Chana (1Kg)', 45, 5, 'Kabuli Chana', '1560280766_of2.png', 'gokhalehemal11@gmail.com', 0),
(5, 17, 14, 'Soya Chunks (1Kg)', 55, 20, 'Soya Chunks', '1560280805_of3.png', 'hemal@gmail.com', 0),
(6, 20, 18, 'Lays (100g)', 20, 20, 'Tasty Spicy Lays', '1560321892_of4.png', 'hemal@gmail.com', 1),
(7, 20, 18, 'Kurkure (100g)', 20, 10, 'Tasty, Spicy and Salty Snack', '1560321938_of5.png', 'hemal@gmail.com', 0),
(8, 20, 18, 'Popcorn (250 g)', 30, 10, 'Tasty Popcorns', '1560322049_of6.png', 'gokhalehemal11@gmail.com', 1),
(9, 20, 14, 'Nuts (250 g)', 45, 50, 'Health Nuts', '1560322089_of7.png', 'gokhalehemal11@gmail.com', 1),
(10, 19, 14, 'Honey (500 g)', 90, 10, 'Fresh, Healthy and Tasty Honey', '1560323321_of12.png', 'hemal@gmail.com', 0),
(11, 19, 18, 'Chocos (250 g)', 55, 10, 'Chocolaty Chocos', '1560323379_of13.png', 'hemal@gmail.com', 0),
(12, 19, 14, 'Oats (1 kg)', 50, 10, 'Healthy Oats', '1560323484_of14.png', 'hemal@gmail.com', 1),
(13, 47, 17, 'Bread (500 g)', 25, 20, 'Brown Bread', '1560323526_of15.png', 'hemal@gmail.com', 1),
(14, 16, 14, 'Banana (6 pcs)', 20, 60, 'Tasty Bananas', '1560323604_of8.png', 'gokhalehemal11@gmail.com', 1),
(15, 16, 14, 'Onion (1 kg)', 20, 20, 'Fresh Onion', '1560323639_of9.png', 'gokhalehemal11@gmail.com', 0),
(16, 16, 14, 'Bitter Gourd (1 kg)', 15, 10, 'Bitter Gourd', '1560323684_of10.png', 'gokhalehemal11@gmail.com', 1),
(17, 16, 14, 'Apples (1 kg)', 100, 20, 'Tasty Red Apples', '1560323747_of11.png', 'gokhalehemal11@gmail.com', 0),
(18, 34, 16, 'Moisturiser (500 g)', 99, 10, 'Moisturize your skin', '1560342395_of16.png', 'hemal@gmail.com', 1),
(19, 67, 15, 'Ribbon (1 pc)', 15, 20, 'Ribbon Your Gifts', '1560342521_of18.png', 'hemal@gmail.com', 1),
(20, 57, 15, 'Clips (10 pc)', 20, 10, 'Clips for your Clothes', '1560342587_of20.png', 'gokhalehemal11@gmail.com', 1),
(21, 31, 16, 'Conditioner (200 g)', 55, 20, 'Hair conditioner', '1560342648_of21.png', 'hemal@gmail.com', 1),
(22, 38, 15, 'Cleaner (500 g)', 70, 20, 'Bathroom Cleaner', '1560342712_of22.png', 'hemal@gmail.com', 0),
(24, 31, 16, 'Hair Gel (250 g)', 60, 25, 'Good hair everyday', '1560342839_of23.png', 'hemal@gmail.com', 1),
(25, 16, 14, 'Grapes (200 g)', 50, 100, 'Fresh and Tasty Green Grapes', '1560342973_of19.png', 'gokhalehemal11@gmail.com', 1),
(26, 16, 14, 'Lady Finger (250 g)', 20, 20, 'Fresh Lady Fingers for your meal', '1560343032_of17.png', 'gokhalehemal11@gmail.com', 1);

-- --------------------------------------------------------

--
-- Table structure for table `vendors`
--

CREATE TABLE `vendors` (
  `id` int(6) UNSIGNED NOT NULL,
  `username` varchar(30) DEFAULT NULL,
  `email` varchar(30) DEFAULT NULL,
  `street` varchar(30) DEFAULT NULL,
  `city` varchar(30) DEFAULT NULL,
  `pincode` varchar(30) DEFAULT NULL,
  `password` varchar(50) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `ifsc` text DEFAULT NULL,
  `pan_card` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `vendors`
--

INSERT INTO `vendors` (`id`, `username`, `email`, `street`, `city`, `pincode`, `password`, `phone`, `ifsc`, `pan_card`) VALUES
(5, 'hemal', 'hemal@gmail.com', 'hdfc colony', 'pune', '411019', 'hemal123', '9518786014', NULL, NULL),
(7, 'Username', 'admin@gmail.com', 'Shivajinagar', 'Pune', '411001', 'admin123', '8149992015', NULL, NULL),
(8, 'Obaida-Grocery', 'Obaida-Grocery@gmail.com', 'STR 2', 'Meghalaya', '411772', 'Obaida-Grocery123', '1223451334', NULL, NULL),
(9, 'Chinmayee', 'gokhalehemal11@gmail.com', 'Chinchwad', 'Pune', '411019', 'c123', '1234567890', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `vouchers`
--

CREATE TABLE `vouchers` (
  `id` int(11) NOT NULL,
  `code` varchar(50) NOT NULL,
  `discount_percent` int(11) NOT NULL,
  `expiry_date` date NOT NULL,
  `usage_limit` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vouchers`
--

INSERT INTO `vouchers` (`id`, `code`, `discount_percent`, `expiry_date`, `usage_limit`) VALUES
(1, 'VOUCHER30', 30, '2024-01-12', 15),
(2, 'VOUCHER20', 20, '2024-01-22', 50),
(3, 'VOUCHER10', 10, '2024-02-01', 100);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`brand_id`);

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`cat_id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `delivery`
--
ALTER TABLE `delivery`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `fk_product_cat` (`product_cat`),
  ADD KEY `fk_product_brand` (`product_brand`);

--
-- Indexes for table `vendors`
--
ALTER TABLE `vendors`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `vouchers`
--
ALTER TABLE `vouchers`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `brands`
--
ALTER TABLE `brands`
  MODIFY `brand_id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `cat_id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int(6) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `delivery`
--
ALTER TABLE `delivery`
  MODIFY `id` int(6) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=96;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(100) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `vendors`
--
ALTER TABLE `vendors`
  MODIFY `id` int(6) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `vouchers`
--
ALTER TABLE `vouchers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `fk_product_brand` FOREIGN KEY (`product_brand`) REFERENCES `brands` (`brand_id`),
  ADD CONSTRAINT `fk_product_cat` FOREIGN KEY (`product_cat`) REFERENCES `categories` (`cat_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
