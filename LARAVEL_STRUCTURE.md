# Laravel Modular Monolith — Proposed Directory Structure

> This document shows the full proposed file/folder layout for the refactored
> Obaida Grocery Store as a **Laravel 11 Modular Monolith**.
> File paths marked with `*` are newly-created files that don't exist in the
> current pure-PHP project.

---

## Root Structure

```
obaida-grocery-store/           (new Laravel project root)
├── app/
│   ├── Modules/                 * all domain modules live here
│   │   ├── Auth/
│   │   ├── Catalog/
│   │   ├── Cart/
│   │   ├── Orders/
│   │   ├── Payments/
│   │   ├── Delivery/
│   │   ├── Communications/
│   │   └── Admin/
│   ├── Http/
│   │   ├── Kernel.php
│   │   └── Middleware/
│   │       ├── Authenticate.php
│   │       ├── EncryptCookies.php
│   │       ├── RedirectIfAuthenticated.php
│   │       ├── TrimStrings.php
│   │       ├── TrustProxies.php
│   │       └── VerifyCsrfToken.php
│   ├── Providers/
│   │   └── AppServiceProvider.php
│   └── Console/
│       └── Kernel.php
├── bootstrap/
├── config/
│   ├── app.php                  (registers all module ServiceProviders)
│   ├── auth.php                 (customer, vendor, admin guards)
│   ├── database.php
│   ├── filesystems.php
│   ├── mail.php
│   ├── queue.php
│   └── services.php             (Stripe keys)
├── database/
│   └── seeders/
│       └── LegacyDataImportSeeder.php  * imports grocery.sql data
├── public/
│   ├── index.php
│   ├── css/ → symlink to storage/app/public
│   └── images/ → legacy assets (copied)
├── resources/
│   ├── css/
│   │   └── app.css              (Bootstrap + custom styles)
│   ├── js/
│   │   └── app.js               (Bootstrap + Alpine.js)
│   └── views/
│       ├── layouts/
│       │   ├── app.blade.php    (customer layout)
│       │   ├── vendor.blade.php
│       │   └── admin.blade.php
│       └── components/
│           ├── product-card.blade.php
│           ├── cart-sidebar.blade.php
│           └── flash-message.blade.php
├── routes/
│   ├── web.php                  (public + customer routes)
│   ├── vendor.php               * vendor dashboard routes
│   ├── admin.php                * admin routes
│   └── api.php                  * optional REST API
├── storage/
├── tests/
│   ├── Feature/                 (module-level feature tests)
│   └── Unit/                    (service/utility unit tests)
├── .env.example                 * all required vars documented
├── .gitignore                   (.env, vendor/, node_modules/, storage/logs/)
├── artisan
├── composer.json
├── package.json
└── vite.config.js
```

---

## Module: Auth

```
app/Modules/Auth/
├── AuthServiceProvider.php         * registers routes, policies, guards
├── Config/
│   └── auth.php                    * module-level guard definitions
├── Database/
│   ├── Migrations/
│   │   ├── 2024_01_01_000001_create_customers_table.php
│   │   ├── 2024_01_01_000002_create_vendors_table.php
│   │   ├── 2024_01_01_000003_create_admins_table.php
│   │   └── 2024_01_01_000004_create_password_reset_tokens_table.php
│   └── Seeders/
│       └── AuthSeeder.php          * imports legacy customers & vendors
├── Events/
│   ├── CustomerRegistered.php
│   ├── VendorRegistered.php
│   └── PasswordResetRequested.php
├── Http/
│   ├── Controllers/
│   │   ├── CustomerAuthController.php
│   │   ├── VendorAuthController.php
│   │   └── AdminAuthController.php
│   ├── Middleware/
│   │   ├── EnsureIsCustomer.php
│   │   ├── EnsureIsVendor.php
│   │   └── EnsureIsAdmin.php
│   └── Requests/
│       ├── RegisterCustomerRequest.php
│       ├── RegisterVendorRequest.php
│       └── LoginRequest.php
├── Models/
│   ├── Customer.php
│   ├── Vendor.php
│   └── Admin.php
├── Services/
│   └── AuthService.php
└── routes/
    └── web.php                     * /login, /register, /logout routes
```

### Key File Examples

#### `app/Modules/Auth/Models/Customer.php`
```php
<?php

namespace App\Modules\Auth\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Contracts\Auth\MustVerifyEmail;

class Customer extends Authenticatable implements MustVerifyEmail
{
    use HasFactory, Notifiable;

    protected $fillable = [
        'username', 'email', 'password',
        'phone', 'street', 'city', 'pincode',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password'          => 'hashed',
        ];
    }

    public function orders()
    {
        return $this->hasMany(\App\Modules\Orders\Models\Order::class);
    }

    public function cartItems()
    {
        return $this->hasMany(\App\Modules\Cart\Models\CartItem::class);
    }
}
```

#### `app/Modules/Auth/Http/Requests/RegisterCustomerRequest.php`
```php
<?php

namespace App\Modules\Auth\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterCustomerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'username' => ['required', 'string', 'max:100', 'unique:customers,username'],
            'email'    => ['required', 'email', 'max:255', 'unique:customers,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'phone'    => ['required', 'string', 'max:20'],
            'street'   => ['required', 'string', 'max:255'],
            'city'     => ['required', 'string', 'max:100'],
            'pincode'  => ['required', 'string', 'max:20'],
        ];
    }
}
```

---

## Module: Catalog

```
app/Modules/Catalog/
├── CatalogServiceProvider.php
├── Database/
│   ├── Migrations/
│   │   ├── 2024_01_02_000001_create_categories_table.php
│   │   ├── 2024_01_02_000002_create_brands_table.php
│   │   └── 2024_01_02_000003_create_products_table.php
│   └── Seeders/
│       └── CatalogSeeder.php       * imports legacy categories, brands, products
├── Events/
│   ├── ProductCreated.php
│   ├── ProductUpdated.php
│   └── ProductDeleted.php
├── Http/
│   ├── Controllers/
│   │   ├── ProductController.php
│   │   ├── CategoryController.php
│   │   └── BrandController.php
│   └── Requests/
│       ├── StoreProductRequest.php
│       └── UpdateProductRequest.php
├── Models/
│   ├── Product.php
│   ├── Category.php
│   └── Brand.php
├── Policies/
│   └── ProductPolicy.php           * vendor can only edit own products
├── Services/
│   ├── ProductService.php
│   └── ImageUploadService.php
└── routes/
    └── web.php
```

### Key File Examples

#### `app/Modules/Catalog/Http/Requests/StoreProductRequest.php`
```php
<?php

namespace App\Modules\Catalog\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user('vendor') !== null;
    }

    public function rules(): array
    {
        return [
            'title'       => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'price'       => ['required', 'numeric', 'min:0.01'],
            'qty'         => ['required', 'integer', 'min:0'],
            'category_id' => ['required', 'exists:categories,id'],
            'brand_id'    => ['required', 'exists:brands,id'],
            'image'       => ['required', 'image', 'mimes:jpeg,png,webp', 'max:2048'],
            'is_egyptian' => ['boolean'],
        ];
    }
}
```

---

## Module: Cart

```
app/Modules/Cart/
├── CartServiceProvider.php
├── Database/
│   └── Migrations/
│       └── 2024_01_03_000001_create_carts_table.php
│       └── 2024_01_03_000002_create_cart_items_table.php
├── Events/
│   ├── ItemAddedToCart.php
│   └── CartMerged.php
├── Http/
│   ├── Controllers/
│   │   └── CartController.php
│   └── Requests/
│       └── AddToCartRequest.php
├── Listeners/
│   └── MergeGuestCartOnLogin.php   * triggered by Auth CustomerRegistered/Login event
├── Models/
│   ├── Cart.php
│   └── CartItem.php
├── Services/
│   └── CartService.php
└── routes/
    └── web.php
```

---

## Module: Orders

```
app/Modules/Orders/
├── OrdersServiceProvider.php
├── Database/
│   └── Migrations/
│       ├── 2024_01_04_000001_create_orders_table.php
│       ├── 2024_01_04_000002_create_order_items_table.php
│       └── 2024_01_04_000003_create_vouchers_table.php
│       └── 2024_01_04_000004_create_voucher_usages_table.php
├── Events/
│   ├── OrderPlaced.php
│   ├── OrderStatusUpdated.php
│   └── OrderCancelled.php
├── Http/
│   ├── Controllers/
│   │   ├── OrderController.php
│   │   └── VoucherController.php
│   └── Requests/
│       ├── PlaceOrderRequest.php
│       └── ApplyVoucherRequest.php
├── Jobs/
│   └── ProcessOrderConfirmation.php
├── Models/
│   ├── Order.php
│   ├── OrderItem.php
│   └── Voucher.php
├── Policies/
│   └── OrderPolicy.php
├── Services/
│   ├── OrderService.php
│   └── VoucherService.php
└── routes/
    └── web.php
```

### Key File Example

#### `app/Modules/Orders/Services/OrderService.php`
```php
<?php

namespace App\Modules\Orders\Services;

use App\Modules\Cart\Services\CartService;
use App\Modules\Orders\Events\OrderPlaced;
use App\Modules\Orders\Models\Order;
use App\Modules\Orders\Models\OrderItem;
use Illuminate\Support\Facades\DB;

class OrderService
{
    public function __construct(
        private readonly CartService $cartService,
    ) {}

    public function placeOrder(array $data, int $customerId): Order
    {
        return DB::transaction(function () use ($data, $customerId) {
            $order = Order::create([
                'customer_id'     => $customerId,
                'shipping_method' => $data['shipping_method'],
                'buyer_address'   => $data['address'],
                'payment_method'  => $data['payment_method'],
                'payment_status'  => 'pending',
                'delivery_status' => 'processing',
            ]);

            $cartItems = $this->cartService->getItemsForCustomer($customerId);

            foreach ($cartItems as $item) {
                OrderItem::create([
                    'order_id'      => $order->id,
                    'product_id'    => $item->product_id,
                    'product_title' => $item->product->title,
                    'product_price' => $item->product->price,
                    'qty'           => $item->qty,
                    'vendor_name'   => $item->product->vendor->username,
                ]);

                // Decrement stock atomically
                $item->product->decrement('qty', $item->qty);
            }

            $this->cartService->clearForCustomer($customerId);

            OrderPlaced::dispatch($order);

            return $order;
        });
    }
}
```

---

## Module: Payments

```
app/Modules/Payments/
├── PaymentsServiceProvider.php
├── Database/
│   └── Migrations/
│       └── 2024_01_05_000001_create_payments_table.php
├── Events/
│   ├── PaymentCompleted.php
│   ├── PaymentFailed.php
│   └── RefundProcessed.php
├── Http/
│   ├── Controllers/
│   │   ├── PaymentController.php
│   │   └── WebhookController.php   * Stripe webhook handler
│   └── Requests/
│       └── CreatePaymentIntentRequest.php
├── Jobs/
│   └── HandleStripeWebhook.php
├── Models/
│   └── Payment.php
├── Services/
│   └── StripePaymentService.php
└── routes/
    └── web.php
```

### Key File Example

#### `app/Modules/Payments/Http/Controllers/WebhookController.php`
```php
<?php

namespace App\Modules\Payments\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Modules\Payments\Jobs\HandleStripeWebhook;
use Illuminate\Http\Request;
use Stripe\Exception\SignatureVerificationException;
use Stripe\WebhookSignature;

class WebhookController extends Controller
{
    public function handle(Request $request)
    {
        $payload = $request->getContent();
        $sigHeader = $request->header('Stripe-Signature');
        $secret = config('services.stripe.webhook_secret');

        try {
            WebhookSignature::verifyHeader($payload, $sigHeader, $secret);
        } catch (SignatureVerificationException $e) {
            return response('Invalid signature', 400);
        }

        $event = json_decode($payload, true);

        HandleStripeWebhook::dispatch($event);

        return response('Webhook received', 200);
    }
}
```

---

## Module: Delivery

```
app/Modules/Delivery/
├── DeliveryServiceProvider.php
├── Database/
│   └── Migrations/
│       ├── 2024_01_06_000001_create_delivery_persons_table.php
│       └── 2024_01_06_000002_create_delivery_assignments_table.php
├── Events/
│   ├── DeliveryAssigned.php
│   └── OrderDelivered.php
├── Http/
│   ├── Controllers/
│   │   └── DeliveryController.php
│   └── Requests/
│       └── AssignDeliveryRequest.php
├── Models/
│   ├── DeliveryPerson.php
│   └── DeliveryAssignment.php
├── Policies/
│   └── DeliveryPolicy.php
├── Services/
│   └── DeliveryAssignmentService.php
└── routes/
    └── web.php
```

---

## Module: Communications

> Named `Communications` (not `Notifications`) to avoid namespace collision with
> Laravel's built-in `Illuminate\Notifications` package.

```
app/Modules/Communications/
├── CommunicationsServiceProvider.php
├── Database/
│   └── Migrations/
│       └── 2024_01_07_000001_create_notifications_table.php
├── Notifications/
│   ├── OrderConfirmedNotification.php
│   ├── OrderShippedNotification.php
│   ├── WelcomeNotification.php
│   └── PasswordResetNotification.php
└── resources/
    └── views/
        └── emails/
            ├── order-confirmed.blade.php
            ├── order-shipped.blade.php
            └── welcome.blade.php
```

### Key File Example

#### `app/Modules/Communications/Notifications/OrderConfirmedNotification.php`
```php
<?php

namespace App\Modules\Communications\Notifications;

use App\Modules\Orders\Models\Order;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class OrderConfirmedNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(private readonly Order $order) {}

    public function via(object $notifiable): array
    {
        return ['mail', 'database'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Your order #' . $this->order->id . ' is confirmed!')
            ->view(
                'notifications::emails.order-confirmed',
                ['order' => $this->order, 'customer' => $notifiable]
            );
    }

    public function toArray(object $notifiable): array
    {
        return [
            'order_id' => $this->order->id,
            'message'  => 'Your order has been confirmed.',
        ];
    }
}
```

---

## Module: Admin

```
app/Modules/Admin/
├── AdminServiceProvider.php
├── Http/
│   ├── Controllers/
│   │   ├── AdminDashboardController.php
│   │   ├── AdminVendorController.php
│   │   ├── AdminOrderController.php
│   │   ├── AdminProductController.php
│   │   └── AdminDeliveryController.php
│   └── Middleware/
│       └── EnsureIsAdmin.php
├── Services/
│   └── AdminDashboardService.php   * aggregates stats across modules
└── routes/
    └── web.php                     * /admin/* routes, all behind EnsureIsAdmin
```

---

## Config: Auth Guards (`config/auth.php` excerpt)

```php
'guards' => [
    'web' => [                          // default (customer)
        'driver'   => 'session',
        'provider' => 'customers',
    ],
    'vendor' => [
        'driver'   => 'session',
        'provider' => 'vendors',
    ],
    'admin' => [
        'driver'   => 'session',
        'provider' => 'admins',
    ],
],

'providers' => [
    'customers' => [
        'driver' => 'eloquent',
        'model'  => App\Modules\Auth\Models\Customer::class,
    ],
    'vendors' => [
        'driver' => 'eloquent',
        'model'  => App\Modules\Auth\Models\Vendor::class,
    ],
    'admins' => [
        'driver' => 'eloquent',
        'model'  => App\Modules\Auth\Models\Admin::class,
    ],
],
```

---

## Route Overview (`routes/web.php`)

```php
<?php

use Illuminate\Support\Facades\Route;

// ── Public routes ──────────────────────────────────────────────────────────
Route::get('/', [\App\Modules\Catalog\Http\Controllers\ProductController::class, 'index']);
Route::get('/products/{product:slug}', [\App\Modules\Catalog\Http\Controllers\ProductController::class, 'show']);
Route::get('/categories/{category:slug}', [\App\Modules\Catalog\Http\Controllers\CategoryController::class, 'show']);
Route::get('/brands/{brand:slug}', [\App\Modules\Catalog\Http\Controllers\BrandController::class, 'show']);

// ── Auth (customer) ────────────────────────────────────────────────────────
Route::middleware('guest')->group(function () {
    Route::get('/login',    [\App\Modules\Auth\Http\Controllers\CustomerAuthController::class, 'showLogin'])->name('login');
    Route::post('/login',   [\App\Modules\Auth\Http\Controllers\CustomerAuthController::class, 'login'])->middleware('throttle:5,1');
    Route::get('/register', [\App\Modules\Auth\Http\Controllers\CustomerAuthController::class, 'showRegister'])->name('register');
    Route::post('/register',[\App\Modules\Auth\Http\Controllers\CustomerAuthController::class, 'register'])->middleware('throttle:10,1');
});
Route::post('/logout', [\App\Modules\Auth\Http\Controllers\CustomerAuthController::class, 'logout'])->middleware('auth')->name('logout');

// ── Cart (guest + auth) ────────────────────────────────────────────────────
Route::prefix('cart')->name('cart.')->group(function () {
    Route::get('/',          [\App\Modules\Cart\Http\Controllers\CartController::class, 'index'])->name('index');
    Route::post('/items',    [\App\Modules\Cart\Http\Controllers\CartController::class, 'add'])->name('add');
    Route::delete('/items/{id}', [\App\Modules\Cart\Http\Controllers\CartController::class, 'remove'])->name('remove');
    Route::post('/voucher',  [\App\Modules\Cart\Http\Controllers\CartController::class, 'applyVoucher'])->name('voucher');
});

// ── Customer (authenticated) ───────────────────────────────────────────────
Route::middleware(['auth', 'verified'])->prefix('customer')->name('customer.')->group(function () {
    Route::get('/checkout',  [\App\Modules\Orders\Http\Controllers\OrderController::class, 'checkout'])->name('checkout');
    Route::post('/checkout', [\App\Modules\Orders\Http\Controllers\OrderController::class, 'place'])->name('place');
    Route::get('/orders',    [\App\Modules\Orders\Http\Controllers\OrderController::class, 'index'])->name('orders.index');
    Route::get('/orders/{order}', [\App\Modules\Orders\Http\Controllers\OrderController::class, 'show'])->name('orders.show');
    Route::get('/pay/{order}',    [\App\Modules\Payments\Http\Controllers\PaymentController::class, 'show'])->name('pay');
    Route::post('/pay/{order}',   [\App\Modules\Payments\Http\Controllers\PaymentController::class, 'process'])->name('pay.process');
});
```

---

## Legacy Data Migration Seeder

```php
<?php
// database/seeders/LegacyDataImportSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class LegacyDataImportSeeder extends Seeder
{
    /**
     * Import data from the legacy grocery.sql dump.
     * Run ONCE after fresh migration on production.
     *
     * php artisan db:seed --class=LegacyDataImportSeeder
     */
    public function run(): void
    {
        // 1. Import customers (re-hash any plain-text passwords)
        $legacyCustomers = DB::connection('legacy')->table('customers')->get();
        foreach ($legacyCustomers as $c) {
            // Detect whether the stored value is already a valid bcrypt hash.
            // password_get_info() returns algo=PASSWORD_BCRYPT for $2y$/$2a$/$2b$
            // prefixed strings. Any other value (plain text, MD5, SHA-1, etc.)
            // will return algo=0 and must be re-hashed.
            $info = password_get_info($c->password);
            $isAlreadyHashed = $info['algo'] !== 0;

            DB::table('customers')->insertOrIgnore([
                'id'         => $c->id,
                'username'   => $c->username,
                'email'      => $c->email,
                'password'   => $isAlreadyHashed
                                    ? (password_needs_rehash($c->password, PASSWORD_BCRYPT)
                                        ? Hash::make($c->password) // upgrade hash params
                                        : $c->password)
                                    : Hash::make($c->password),   // re-hash plain text
                'phone'      => $c->phone,
                'street'     => $c->street,
                'city'       => $c->city,
                'pincode'    => $c->pincode,
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        // 2. Import categories, brands, products (similar pattern) ...
        // 3. Import vendors (excluding superadmin — create Admin record separately) ...
        // 4. Import orders, vouchers, delivery ...
    }
}
```

---

## Summary: Cross-Module Event Flow

```
Customer registers
  └─► Auth::CustomerRegistered
        └─► Communications::WelcomeNotification (queued mail)
Customer adds item to cart
  └─► Cart::ItemAddedToCart

Customer logs in
  └─► Cart::CartMerged (guest cart → user cart)

Customer places order
  └─► Orders::OrderPlaced
        ├─► Payments: payment intent created (or COD flagged)
        └─► Communications::OrderConfirmedNotification (queued mail)

Stripe webhook fires payment_intent.succeeded
  └─► Payments::PaymentCompleted
        └─► Orders: order status → confirmed
        └─► Communications::OrderShippedNotification (queued when dispatched)

Admin assigns delivery person
  └─► Delivery::DeliveryAssigned
        └─► Notifications: notify delivery person (mail)

Delivery person marks delivered
  └─► Delivery::OrderDelivered
        └─► Orders: order status → delivered
        └─► Notifications: notify customer (mail)
```
