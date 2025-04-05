# README

#  Cash Register API - Backend

This is the **Ruby on Rails API backend** for the **Cash Register** application built as part of the Amenitiz technical evaluation.

The API is responsible for:

- Managing **products**
- Managing **promotions**
- Calculating the **total price** of a basket with promotional rules applied

It is designed to be simple, readable, maintainable, and easily extensible. The backend is fully tested following **TDD (Test-Driven Development)** methodology.

---

##  Tech Stack

- **Ruby version:** 3.2.2  
- **Rails version:** 7.x  
- **Database:** SQLite3 (for development, can be changed)  
- **Testing Framework:** RSpec  

---

##  System Dependencies

Ensure you have the following installed:

- Ruby >= 3.2.2  
- Rails >= 7.0  
- Bundler  
- SQLite3  
- Node.js & Yarn (for JS assets, optional)  

---

##  Setup & Configuration

### 1. Clone the repository

bash

git clone <repository-url>
cd cash-register-backend

### 2. Install dependencies

bash
bundle install

### 3. Create and migrate the database

bash
bin/rails db:create db:migrate db:seed

### 4. Run the Rails server

bash
rails server

---

###  Running the Test Suite

bash
bundle exec rspec

---

### API Endpoints
## Health Check
GET /up
Returns a simple JSON response indicating the API is running.

---
## Products

List all products
GET /products

Search products by name or code
GET /products?search=gr1

Show a single product
GET /products/:id

Create a product
POST /products
Content-Type: application/json
{
  "product": {
    "name": "Green Tea",
    "code": "GR1",
    "price": 3.11
  }
}

Update a product
PATCH /products/:id

Delete a product
DELETE /products/:id

---
## Promotions

List all promotions
GET /promotions

Search promotions by name
GET /promotions?name=coffee

Show a single promotion
GET /promotions/:id

Create a promotion
POST /promotions
Content-Type: application/json
{
  "promotion": {
    "name": "BOGO Green Tea",
    "promotion_type": "buy_one_get_one_free",
    "product_id": 1,
    "trigger_quantity": 2
  }
}

Accepted promotion_type values:
buy_one_get_one_free
bulk_discount_price
bulk_discount_percentage

Update a promotion
PATCH /promotions/:id

Delete a promotion
DELETE /promotions/:id

---
## Checkout
Calculates the total for a basket of product codes, applying any valid promotions.

POST /checkout
Content-Type: application/json
{
  "product_codes": ["GR1", "CF1", "SR1", "CF1", "CF1"]
}
Response:
json
{
  "total": 30.57,
  "promotions": [
    {
      "name": "Coffee Bulk Discount",
      "savings": 11.23
    },
    {
      "name": "BOGO Green Tea",
      "savings": 3.11
    }
  ]
}

## Pricing Rules Implemented
The pricing logic is handled in app/services/compute_total_service.rb. It supports:

BOGO (Buy-One-Get-One-Free) for Green Tea (GR1)

Bulk price discount for Strawberries (SR1) – price drops to €4.50 when buying 3+

Bulk percentage discount for Coffee (CF1) – price drops to 2/3 when buying 3+

Promotions are defined in the database and can be created/updated via the /promotions API.

---
###  Project Structure Overview
app/controllers/ — RESTful API endpoints

app/models/ — Data models for Product and Promotion

app/services/compute_total_service.rb — Business logic to compute the total

spec/ — RSpec test suite (unit and request specs)

config/routes.rb — Defines all API routes

### Design Principles
Built with TDD from the beginning

Clean separation of concerns (controllers, services, models)

Easily extendable for future promotion types or pricing rules

Designed to support both human and programmatic use

### Contact
If you have any questions, suggestions or issues, feel free to create a GitHub issue or reach out.
