# ObaidaGroceryStore

## Overview

**ObaidaGroceryStore** is a robust online grocery shopping platform designed to streamline the grocery shopping experience. It connects customers with a wide range of products from various vendors, offering a seamless and user-friendly environment for online grocery purchases. The platform is still under active development, with ongoing improvements and optimizations.

## Key Features

- **User Accounts**: Comprehensive portals for both customers and vendors, each with tailored features.
- **Product Catalog**: Dynamic and detailed product listings to help customers find what they need quickly.
- **Shopping Cart**: Enhanced functionality for an intuitive, seamless shopping cart experience.
- **Order Management**: A robust system for tracking and managing orders efficiently.
- **Vendor Management**: Specialized interface for vendors to manage product listings, view orders, and monitor sales performance.

## System Requirements

- **PHP**: Version 7.x or higher (recommended)
- **MySQL**: Version 5.6 or higher
- **Web Server**: Apache or any PHP-compatible server

## Installation Guide

### Step 1: Prepare the Environment
Make sure **PHP**, **MySQL**, and **Apache** (or equivalent server) are installed on your system. For a straightforward setup, tools like **XAMPP**, **WAMP**, or **MAMP** can be used to provide an all-in-one solution.

### Step 2: Clone the Repository
Clone the repository to your local machine using the following command:
```bash
git clone https://github.com/hussiensulyman/Obaida-Grocery-Store/
```

### Step 3: Database Configuration
- Create a MySQL database (e.g., `obaidagrocerystore`).
- Import the `grocery.sql` file (located in the `database/` folder) to set up the required tables and initial data.

### Step 4: Configure the Project
- Ensure your web server is configured to point to the project's root directory.
- Open the `config.php` file (or equivalent) and update the database connection settings to reflect your database credentials (e.g., database name, username, and password).

### Step 5: Launch the Application
- After configuration, access the application through your web server (e.g., `http://localhost/`).
- The default landing page will be `index.php`.

## Usage Instructions

### For Customers:
1. Register for a customer account.
2. Browse the product catalog.
3. Add items to your shopping cart.
4. Complete your order by proceeding to checkout.

### For Vendors:
1. Register for a vendor account.
2. Add products to the catalog.
3. Manage existing product listings.
4. View and manage customer orders.

## Known Issues

- The project currently contains a few bugs affecting certain features. These issues are being actively worked on and will be addressed in future updates.
- The platform is undergoing refactoring to improve code quality, enhance performance, and ensure a smoother user experience.

## Project Directory Structure

- **Root Directory**: Contains the main PHP files for the application.
- **`css/`**: Stores stylesheets used across the application.
- **`js/`**: Contains JavaScript files for front-end functionality.
- **`images/`**: Stores images used throughout the platform.
- **`templates/`**: Holds reusable components like headers and footers.
- **`database/`**: Includes database schema and setup scripts.
