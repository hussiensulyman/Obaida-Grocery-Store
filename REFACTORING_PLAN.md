# Obaida Grocery Store — Laravel Refactoring Plan

> **Objective:** Migrate the existing pure-PHP multi-vendor grocery store to **Laravel 11** using a **Modular Monolith** architecture that is scalable, maintainable, and secure.

---

## Table of Contents

1. [Current State Analysis](#1-current-state-analysis)
2. [Target Architecture](#2-target-architecture)
3. [Module Breakdown](#3-module-breakdown)
4. [Database Migration Strategy](#4-database-migration-strategy)
5. [Security Hardening Plan](#5-security-hardening-plan)
6. [API & Routing Design](#6-api--routing-design)
7. [Front-End Strategy](#7-front-end-strategy)
8. [Testing Strategy](#8-testing-strategy)
9. [Phased Implementation Roadmap](#9-phased-implementation-roadmap)
10. [Infrastructure & DevOps](#10-infrastructure--devops)

---

## 1. Current State Analysis

### 1.1 Tech Stack (Current)

| Concern         | Technology                         |
|-----------------|------------------------------------|
| Language        | PHP (procedural, no framework)     |
| Database        | MySQL 5.6+ via MySQLi              |
| Auth            | `$_SESSION` variables              |
| Payments        | Stripe PHP SDK v13.7               |
| Email           | PHPMailer (bundled manually)       |
| Front-end       | Inline HTML, jQuery, Bootstrap     |
| Dependencies    | Composer (Stripe only)             |

### 1.2 Identified Issues

#### Security Vulnerabilities
- **SQL Injection** — Raw string interpolation in all queries (no prepared statements).
- **Plain-text passwords** — Several records stored unhashed in the database.
- **`extract($_POST)`** — Directly pollutes variable scope; trivial to exploit.
- **No CSRF protection** — All forms submit without tokens.
- **Hardcoded credentials** — DB host/user/password in `classes/Database.php`.
- **No rate limiting** — Login/register endpoints are brute-forceable.
- **File upload validation absent** — Product images are not validated by MIME type or size.
- **XSS** — User-supplied values echoed without escaping (e.g., `echo $_GET['search']`).

#### Architecture Problems
- No separation of concerns — business logic, HTML, and SQL mixed in the same file.
- No routing — URL structure is tightly coupled to file names.
- No environment configuration — credentials committed to source control.
- Duplicate code — cart/checkout logic repeated across multiple files.
- No input validation layer — validation done inline (or not at all).
- No error handling — raw MySQLi errors exposed to end users.

### 1.3 Existing Domain Entities

```
customers      — shoppers (id, username, email, password, phone, address)
vendors        — sellers + one superadmin (id, username, email, password, banking details)
products       — catalog items (id, category_id, brand_id, title, price, qty, image, vendor)
categories     — product taxonomy (id, title, slug, vendor)
brands         — brand/supplier info (id, title, vendor)
orders         — purchase records (id, product, buyer, payment, delivery status)
cart           — session/IP-based line items (id, product_id, qty, ip, user_id)
vouchers       — discount codes (id, code, discount_percent, expiry, usage_limit)
delivery       — delivery personnel (id, username, email, phone, address)
```

---

## 2. Target Architecture

### 2.1 Pattern: Modular Monolith

A **Modular Monolith** deploys as a single application (one codebase, one process, one database) but organises code into strongly bounded, independently maintainable **modules**. This gives:

- **Scalability path** — Each module can be extracted into a microservice later with minimal rewrites.
- **Team autonomy** — Teams can own individual modules with clear interfaces.
- **Simplicity** — No distributed-systems overhead (no service mesh, no inter-service HTTP).
- **Laravel fit** — Laravel's service providers, events, and queue system map cleanly to module boundaries.

### 2.2 High-Level Directory Layout

> All domain modules — including `Admin` — live under `app/Modules/`. Core Laravel
> infrastructure directories (`Http/Kernel.php`, `Providers/`, `Console/`) sit at
> `app/` level as they are framework-level concerns, not domain modules.

```
app/
├── Modules/
│   ├── Auth/
│   ├── Catalog/
│   ├── Cart/
│   ├── Orders/
│   ├── Payments/
│   ├── Delivery/
│   ├── Communications/
│   └── Admin/
├── Http/
│   └── Kernel.php
├── Providers/
│   └── AppServiceProvider.php
└── Console/
    └── Kernel.php

config/
database/
│   ├── migrations/
│   └── seeders/
resources/
routes/
│   ├── web.php          (public + customer routes)
│   ├── vendor.php       (vendor dashboard routes)
│   ├── admin.php        (admin routes)
│   └── api.php          (optional REST API)
tests/
```

### 2.3 Module Internal Structure

Every module follows the same internal layout:

```
app/Modules/{ModuleName}/
├── Config/
│   └── {module}.php          # Module-specific config
├── Database/
│   ├── Migrations/            # Module-owned migrations
│   └── Seeders/
├── Events/                    # Domain events
├── Exceptions/                # Module exceptions
├── Http/
│   ├── Controllers/
│   ├── Middleware/
│   └── Requests/              # Form Request validation classes
├── Jobs/                      # Queued jobs
├── Listeners/                 # Event listeners
├── Models/                    # Eloquent models
├── Policies/                  # Authorization policies
├── Repositories/              # Data access layer (optional)
├── Services/                  # Business logic
├── routes/
│   ├── web.php
│   └── api.php
└── {ModuleName}ServiceProvider.php
```

Each module registers itself through its `ServiceProvider`, which is listed in `config/app.php`.

---

## 3. Module Breakdown

### 3.1 Auth Module

**Responsibility:** Registration, login, logout, password reset for all user types (Customer, Vendor, Admin).

| Component | Details |
|-----------|---------|
| **Models** | `Customer`, `Vendor`, `Admin` (or a polymorphic `User` with `role`) |
| **Guards** | `customer` (web), `vendor` (web), `admin` (web) — configured in `config/auth.php` |
| **Controllers** | `CustomerAuthController`, `VendorAuthController`, `AdminAuthController` |
| **Requests** | `RegisterCustomerRequest`, `RegisterVendorRequest`, `LoginRequest` |
| **Services** | `AuthService` (handles hashing, token generation) |
| **Events** | `CustomerRegistered`, `VendorRegistered`, `PasswordResetRequested` |
| **Middleware** | `EnsureEmailIsVerified`, `RedirectIfAuthenticated` |

**Security measures:**
- All passwords hashed with `bcrypt` (via `Hash::make()`).
- Email verification via `MustVerifyEmail` contract.
- Password reset via signed URLs (Laravel's built-in `Password` facade).
- Rate limiting on login: `throttle:5,1` (5 attempts per minute).

**Migration from legacy:**
- Existing `customers` and `vendors` tables retain data.
- A one-time migration script re-hashes any plain-text passwords.

---

### 3.2 Catalog Module

**Responsibility:** Products, categories, and brands management.

| Component | Details |
|-----------|---------|
| **Models** | `Product`, `Category`, `Brand` |
| **Controllers** | `ProductController`, `CategoryController`, `BrandController` |
| **Requests** | `StoreProductRequest`, `UpdateProductRequest` |
| **Services** | `ProductService`, `ImageUploadService` |
| **Events** | `ProductCreated`, `ProductUpdated`, `ProductDeleted` |
| **Policies** | `ProductPolicy` (vendor can only edit own products) |

**Key improvements:**
- File upload validation: MIME type whitelist (`image/jpeg`, `image/png`, `image/webp`), max size 2 MB, stored via `Storage::disk('public')`.
- Slug-based URLs for categories and brands (SEO-friendly).
- Soft deletes on `products` to preserve order history.
- Full-text search via Laravel Scout (backed by database or Meilisearch).
- `isEgyptian` flag retained as boolean on the `products` table.

---

### 3.3 Cart Module

**Responsibility:** Shopping cart for both guests (cookie-based) and authenticated customers (DB-backed).

| Component | Details |
|-----------|---------|
| **Models** | `Cart`, `CartItem` |
| **Controllers** | `CartController` |
| **Services** | `CartService` (merge guest→user cart on login) |
| **Events** | `ItemAddedToCart`, `CartMerged` |

**Key improvements:**
- Replace IP-address-based guest tracking with signed session cookies.
- On customer login, `CartMerged` event triggers merge of guest cart into user cart.
- Cart totals calculated server-side (never trust client-submitted prices).
- Voucher validation handled by `CartService` → delegates to `VoucherService` in Orders module.

---

### 3.4 Orders Module

**Responsibility:** Order lifecycle from placement through delivery.

| Component | Details |
|-----------|---------|
| **Models** | `Order`, `OrderItem`, `Voucher` |
| **Controllers** | `OrderController`, `VoucherController` |
| **Requests** | `PlaceOrderRequest`, `ApplyVoucherRequest` |
| **Services** | `OrderService`, `VoucherService` |
| **Events** | `OrderPlaced`, `OrderStatusUpdated`, `OrderCancelled` |
| **Jobs** | `ProcessOrderConfirmation` (queued) |
| **Policies** | `OrderPolicy` (customer can only view own orders; vendor sees own products) |

**Key improvements:**
- Atomic order creation inside a database transaction.
- `OrderItem` table decouples line items from product (preserves price history).
- Status machine: `pending → confirmed → dispatched → delivered | cancelled | returned`.
- Voucher: enforces `usage_limit`, `expiry_date`, per-user single-use via pivot table.

---

### 3.5 Payments Module

**Responsibility:** Payment processing via Stripe; payment records.

| Component | Details |
|-----------|---------|
| **Models** | `Payment` |
| **Controllers** | `PaymentController`, `WebhookController` |
| **Services** | `StripePaymentService` |
| **Events** | `PaymentCompleted`, `PaymentFailed`, `RefundProcessed` |
| **Jobs** | `HandleStripeWebhook` |

**Key improvements:**
- Stripe secret key loaded from `.env` (`STRIPE_SECRET`, `STRIPE_WEBHOOK_SECRET`).
- Webhook endpoint verified using `Stripe\WebhookSignature` — prevents spoofed events.
- Payment records stored locally for audit trail and refund support.
- COD (Cash on Delivery) handled as a separate payment method with `payment_status = 'cod_pending'`.

---

### 3.6 Delivery Module

**Responsibility:** Delivery personnel management and order assignment.

| Component | Details |
|-----------|---------|
| **Models** | `DeliveryPerson`, `DeliveryAssignment` |
| **Controllers** | `DeliveryController` |
| **Requests** | `AssignDeliveryRequest` |
| **Services** | `DeliveryAssignmentService` |
| **Events** | `DeliveryAssigned`, `OrderDelivered` |
| **Policies** | `DeliveryPolicy` (admin/vendor only) |

---

### 3.7 Communications Module

**Responsibility:** All outbound communications (email, in-app alerts). Named `Communications` (not `Notifications`) to avoid namespace collision with Laravel's built-in `Illuminate\Notifications` package.

| Component | Details |
|-----------|---------|
| **Notifications** | `OrderConfirmedNotification`, `OrderShippedNotification`, `WelcomeNotification`, `PasswordResetNotification` |
| **Mailables** | Blade-based email templates replacing raw PHPMailer HTML strings |
| **Channels** | `mail` (default), `database` (in-app), `broadcast` (future) |

**Key improvements:**
- Replace bundled PHPMailer with **Laravel Notifications** + `Mail` facade (supports SMTP, Mailgun, SES).
- Email config via `.env` (`MAIL_MAILER`, `MAIL_HOST`, `MAIL_USERNAME`, `MAIL_PASSWORD`).
- Queue notifications to avoid blocking HTTP response (`ShouldQueue`).
- Namespace: `App\Modules\Communications\Notifications\*` — no conflict with `Illuminate\Notifications`.

---

### 3.8 Admin Module

**Responsibility:** Superadmin dashboard — manage vendors, orders, delivery, products, vouchers, categories.

| Component | Details |
|-----------|---------|
| **Controllers** | `AdminDashboardController`, `AdminVendorController`, `AdminOrderController` |
| **Middleware** | `EnsureIsAdmin` |
| **Services** | Delegates to other module services |
| **Policies** | All `Admin` guard — separated from `vendor`/`customer` |

**Key improvement:** Remove the "superadmin = special vendor email" anti-pattern. The `Admin` model (or `User` with `role = admin`) is a first-class entity with its own guard.

---

## 4. Database Migration Strategy

### 4.1 Principles

1. All schema changes managed with **Laravel migrations** (never manual SQL edits).
2. Each module owns its migrations (stored in `app/Modules/{Module}/Database/Migrations/`).
3. Existing data preserved via a seeder-based import from the legacy `grocery.sql` dump.
4. Foreign keys and indexes made explicit.

### 4.2 Schema Changes

#### `customers` table → **no rename**
```sql
-- Add columns
ALTER TABLE customers ADD COLUMN email_verified_at TIMESTAMP NULL;
ALTER TABLE customers ADD COLUMN remember_token VARCHAR(100) NULL;
ALTER TABLE customers ADD COLUMN created_at TIMESTAMP NULL;
ALTER TABLE customers ADD COLUMN updated_at TIMESTAMP NULL;
-- Re-hash plain-text passwords (via seeder/migration script)
```

#### `vendors` table → **no rename**
```sql
ALTER TABLE vendors ADD COLUMN email_verified_at TIMESTAMP NULL;
ALTER TABLE vendors ADD COLUMN remember_token VARCHAR(100) NULL;
ALTER TABLE vendors ADD COLUMN is_superadmin TINYINT(1) DEFAULT 0;
ALTER TABLE vendors ADD COLUMN created_at TIMESTAMP NULL;
ALTER TABLE vendors ADD COLUMN updated_at TIMESTAMP NULL;
```

#### New tables

| Table | Purpose |
|-------|---------|
| `admins` | Dedicated superadmin accounts |
| `order_items` | Line-item split from monolithic `orders` |
| `payments` | Payment audit trail |
| `delivery_assignments` | Order ↔ delivery person pivot |
| `voucher_usages` | Track per-user voucher redemptions |
| `password_reset_tokens` | Laravel's built-in reset flow |
| `jobs` / `failed_jobs` | Queue worker tables |
| `sessions` | DB-backed session storage |
| `notifications` | In-app notification storage |

### 4.3 Eloquent Model Relationships

```
Customer  hasMany  Orders
Customer  hasMany  CartItems
Customer  hasMany  Notifications

Vendor    hasMany  Products
Vendor    hasMany  Orders (as seller)

Product   belongsTo  Category
Product   belongsTo  Brand
Product   belongsTo  Vendor
Product   hasMany    OrderItems
Product   hasMany    CartItems

Order     belongsTo  Customer
Order     hasMany    OrderItems
Order     hasOne     Payment
Order     hasOne     DeliveryAssignment

Voucher   belongsToMany  Orders  (via voucher_usages)

DeliveryPerson  hasMany  DeliveryAssignments
```

---

## 5. Security Hardening Plan

| # | Vulnerability | Fix |
|---|--------------|-----|
| 1 | SQL Injection | Eloquent ORM / `DB::select()` with bindings — no raw string interpolation |
| 2 | Plain-text passwords | `Hash::make()` on all passwords; one-time migration for existing records |
| 3 | `extract($_POST)` | Replace with `$request->validated()` from Form Request classes |
| 4 | No CSRF | Laravel's `VerifyCsrfToken` middleware enabled globally on web routes |
| 5 | Hardcoded credentials | `.env` file; `.env` added to `.gitignore`; `config/database.php` reads `env()` |
| 6 | No rate limiting | `throttle:5,1` on login; `throttle:10,1` on register |
| 7 | File upload abuse | Validate MIME (`image/*`), max 2 MB, store outside web root via `Storage` |
| 8 | XSS | Blade templates use `{{ }}` (auto-escaped); `{!! !!}` only where explicitly safe |
| 9 | Mass assignment | Explicit `$fillable` / `$guarded` on every Eloquent model |
| 10 | Broken access control | Gate/Policy for every sensitive action; `can()` checks in controllers |
| 11 | Webhook spoofing | Stripe webhook signature verification via `Stripe\WebhookSignature::verifyHeader()` |
| 12 | Session fixation | `session()->regenerate()` on successful login |
| 13 | Sensitive data exposure | Remove `dd()`, raw error output; `APP_DEBUG=false` in production |
| 14 | Dependency vulnerabilities | `composer audit` in CI pipeline; `dependabot` alerts enabled |
| 15 | Insecure direct object reference | All model lookups scoped to authenticated user (e.g., `auth()->user()->orders()->findOrFail($id)`) |

---

## 6. API & Routing Design

### 6.1 Web Routes

```
GET  /                          → Catalog: product listing
GET  /products/{slug}           → Catalog: product detail
GET  /categories/{slug}         → Catalog: category products
GET  /cart                      → Cart: view cart
POST /cart/items                → Cart: add item
DELETE /cart/items/{id}         → Cart: remove item
POST /cart/voucher              → Cart: apply voucher

GET  /checkout                  → Orders: checkout page
POST /checkout                  → Orders: place order
GET  /order-success/{id}        → Orders: confirmation page

GET  /login                     → Auth: customer login form
POST /login                     → Auth: authenticate customer
GET  /register                  → Auth: registration form
POST /register                  → Auth: register customer
POST /logout                    → Auth: logout

GET  /customer/orders           → Orders: customer order history
GET  /customer/orders/{id}      → Orders: order detail

GET  /vendor/login              → Auth: vendor login
GET  /vendor/dashboard          → Vendor: dashboard
GET  /vendor/products           → Catalog: vendor products
POST /vendor/products           → Catalog: create product
...

GET  /admin/dashboard           → Admin: dashboard
...
```

### 6.2 Optional REST API (for future mobile app)

All API routes under `/api/v1/`, protected by `sanctum` (token-based auth):

```
POST /api/v1/auth/login
POST /api/v1/auth/register
GET  /api/v1/products
GET  /api/v1/products/{id}
GET  /api/v1/cart
POST /api/v1/cart/items
POST /api/v1/orders
GET  /api/v1/orders/{id}
POST /api/v1/payments/intent
POST /api/v1/payments/webhook   (Stripe)
```

---

## 7. Front-End Strategy

### Option A — Blade + Alpine.js (Recommended for initial migration)

- Keep existing Bootstrap-based UI; replace inline PHP with Blade templates.
- Add **Alpine.js** for reactive cart counter, quantity controls, and form validation.
- Use **Vite** (Laravel's default bundler) to compile CSS/JS.
- Layout: `resources/views/layouts/app.blade.php` with `@yield` sections.
- Reusable components: `<x-product-card>`, `<x-cart-sidebar>`, `<x-flash-message>`.

### Option B — Inertia.js + Vue/React (For future SPA)

- Server-side routing, client-side rendering with shared data via page props.
- Enables gradual extraction of modules into a separate front-end later.

### Recommendation

Start with **Option A** to reduce scope during migration, then migrate to Option B module-by-module once the back-end architecture is stable.

---

## 8. Testing Strategy

### 8.1 Test Layers

| Layer | Tool | Scope |
|-------|------|-------|
| Unit | PHPUnit | Services, value objects, utilities |
| Feature | PHPUnit + `RefreshDatabase` | HTTP requests, controllers, policies |
| Integration | PHPUnit | Payment service (Stripe mocked), mail |
| Browser | Pest + Dusk (optional) | Critical user journeys (checkout flow) |

### 8.2 Priority Test Coverage

1. **Auth module** — registration, login, email verification, password reset.
2. **Cart module** — add/remove/merge, voucher application, price calculation.
3. **Orders module** — order placement, stock decrement, status transitions.
4. **Payments module** — Stripe payment intent creation, webhook handling.
5. **Catalog module** — product CRUD, image upload validation, policy enforcement.

### 8.3 CI Integration

- Run `php artisan test --parallel` on every PR.
- `composer audit` to scan for known vulnerable dependencies.
- PHPStan (level 6+) for static analysis.
- Laravel Pint for code style enforcement.

---

## 9. Phased Implementation Roadmap

### Phase 1 — Foundation (Week 1–2)

- [ ] Install Laravel 11 in a clean directory (`composer create-project laravel/laravel`).
- [ ] Configure `.env` (DB credentials, app key, Stripe keys, mail).
- [ ] Install module scaffolding (`nwidart/laravel-modules` or custom `ModuleServiceProvider`).
- [ ] Create `Auth` module: models, guards, migrations, controllers, email verification.
- [ ] Migrate `customers` and `vendors` tables; import legacy data via seeders.
- [ ] Set up Vite, copy existing CSS/Bootstrap assets.
- [ ] Implement basic customer login/register flow end-to-end.

### Phase 2 — Catalog & Cart (Week 3–4)

- [ ] Create `Catalog` module: `Product`, `Category`, `Brand` models + migrations.
- [ ] Vendor product management (CRUD with policy-based authorization).
- [ ] Product image upload with validation via `Storage`.
- [ ] Public product listing, category browsing, search (Scout/database driver).
- [ ] Create `Cart` module: guest + authenticated cart, merge on login.
- [ ] Apply `CSRF` middleware, sanitize all inputs with Form Requests.

### Phase 3 — Orders & Payments (Week 5–6)

- [ ] Create `Orders` module: `Order`, `OrderItem`, `Voucher` models + migrations.
- [ ] Checkout flow: address collection, shipping selection, order placement inside DB transaction.
- [ ] Create `Payments` module: Stripe integration, `PaymentController`, `WebhookController`.
- [ ] Stripe webhook signature verification.
- [ ] COD payment path.
- [ ] Order confirmation email via `Communications` module.

### Phase 4 — Delivery, Admin & Communications (Week 7–8)

- [ ] Create `Delivery` module: delivery personnel management, order assignment.
- [ ] Create `Admin` module: superadmin dashboard, vendor management, site-wide stats.
- [ ] Complete `Communications` module: all email notifications converted to `Notification` classes.
- [ ] Queue workers configured (Redis or database driver).
- [ ] Password reset flow fully functional.

### Phase 5 — Hardening & QA (Week 9–10)

- [ ] Security audit: run `php artisan route:list` and verify every route has appropriate middleware.
- [ ] Add `throttle` to all auth endpoints.
- [ ] Run PHPStan (level 6) and fix all errors.
- [ ] Write feature tests for all critical flows (target ≥ 80% coverage on modules).
- [ ] Enable `APP_DEBUG=false`, configure proper error handling (`Handler.php`).
- [ ] Run `composer audit`; update any vulnerable packages.
- [ ] Load test checkout + cart with a basic benchmark tool.

### Phase 6 — Deployment & Monitoring (Week 11–12)

- [ ] Set up `.github/workflows/ci.yml` (lint → test → audit → build).
- [ ] Configure production `.env` (DB, Stripe live keys, mail, Redis).
- [ ] Set up queue worker as a supervised process (Supervisor or Laravel Horizon).
- [ ] Enable Laravel Telescope in staging for request/query monitoring.
- [ ] Configure log aggregation (e.g., Sentry for exceptions, Papertrail for logs).
- [ ] Database backup strategy (daily `mysqldump` + off-site storage).

---

## 10. Infrastructure & DevOps

### 10.1 Recommended Stack

| Concern | Technology |
|---------|-----------|
| Runtime | PHP 8.3 + Laravel 11 |
| Web server | Nginx + PHP-FPM |
| Database | MySQL 8.x |
| Cache | Redis |
| Queue driver | Redis (or `database` for simpler setups) |
| Session driver | Redis (or `database`) |
| File storage | Local `storage/app/public` (dev) / AWS S3 (prod) |
| Email | SMTP / Mailgun / SES (via `.env`) |
| CI | GitHub Actions |
| Error tracking | Sentry |

### 10.2 Environment Variables

```dotenv
APP_NAME="Obaida Grocery Store"
APP_ENV=production
APP_KEY=                        # generated by php artisan key:generate
APP_DEBUG=false
APP_URL=https://yourdomain.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=obaidagrocerystore
DB_USERNAME=
DB_PASSWORD=

CACHE_STORE=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis

MAIL_MAILER=smtp
MAIL_HOST=
MAIL_PORT=587
MAIL_USERNAME=
MAIL_PASSWORD=
MAIL_FROM_ADDRESS=noreply@yourdomain.com
MAIL_FROM_NAME="${APP_NAME}"

STRIPE_KEY=                     # publishable key
STRIPE_SECRET=                  # secret key
STRIPE_WEBHOOK_SECRET=          # for webhook signature verification

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

### 10.3 GitHub Actions CI Pipeline (`.github/workflows/ci.yml` outline)

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_DATABASE: testing
          MYSQL_ROOT_PASSWORD: secret
    steps:
      - uses: actions/checkout@v4
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.3'
          extensions: pdo_mysql, redis
      - name: Install dependencies
        run: composer install --prefer-dist --no-progress
      - name: Security audit
        run: composer audit
      - name: Run Pint (code style)
        run: ./vendor/bin/pint --test
      - name: Run PHPStan
        run: ./vendor/bin/phpstan analyse
      - name: Run tests
        run: php artisan test --parallel
        env:
          DB_CONNECTION: mysql
          DB_DATABASE: testing
          DB_USERNAME: root
          DB_PASSWORD: secret
```

---

## Summary

| Dimension | Current | After Refactor |
|-----------|---------|----------------|
| Framework | None (procedural PHP) | Laravel 11 |
| Architecture | Spaghetti (file-per-page) | Modular Monolith (8 modules) |
| Auth | `$_SESSION` + manual hashing | Laravel Guards + Sanctum (API) |
| DB access | Raw MySQLi (SQL injection risk) | Eloquent ORM + query bindings |
| Validation | Inline/none | Form Request classes per endpoint |
| Security | Multiple critical vulnerabilities | OWASP Top 10 addressed |
| Passwords | Mixed (plain + hashed) | Bcrypt (all records) |
| Email | Bundled PHPMailer | Laravel Notifications (queued) |
| Payments | Basic Stripe | Stripe + webhook verification |
| Tests | None | PHPUnit feature + unit tests |
| CI/CD | None | GitHub Actions pipeline |
| Config mgmt | Hardcoded | `.env`-based |
| Scalability | Single file, no abstractions | Module-level separation; microservice-ready |
