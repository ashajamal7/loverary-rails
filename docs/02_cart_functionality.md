# Cart Functionality API Documentation

This document explains how to manage shopping cart operations with the Loverary API. The API provides a session-based shopping cart that persists for authenticated users.

## Table of Contents
1. [Authentication Requirements](#authentication-requirements)
2. [Get Active Cart](#get-active-cart)
3. [Create New Cart](#create-new-cart)
4. [Add Items to Cart](#add-items-to-cart)
5. [Update Cart Item Quantity](#update-cart-item-quantity)
6. [Remove Item from Cart](#remove-item-from-cart)
7. [Clear Cart](#clear-cart)
8. [Checkout](#checkout)
9. [Error Handling](#error-handling)

## Authentication Requirements

All cart endpoints require authentication. The following headers must be included in all requests:

- `Cookie`: `_loverary_session=<session_token>` (automatically handled by browsers)
- `X-CSRF-Token`: `<csrf_token>` (required for non-GET requests)
- `Content-Type`: `application/json` (for requests with a body)

To get started with the cart API:
1. Authenticate the user (see Authentication API)
2. Fetch the CSRF token using `GET /users/csrf-token`
3. Include the token in the `X-CSRF-Token` header for all non-GET requests

## Get Active Cart

Retrieve the current user's active cart with all its items.

**Endpoint**: `GET /carts/active`

### Headers
- `Cookie`: `_loverary_session=<session_token>` (automatically handled by browser)

### Success Response (200 OK)
```json
{
  "message": "Cart retrieved",
  "cart": {
    "id": 123,
    "user_id": 1,
    "status": "active",
    "created_at": "2025-08-03T00:00:00.000Z",
    "updated_at": "2025-08-03T00:05:00.000Z",
    "cart_items": [
      {
        "book_id": 1,
        "quantity": 2,
        "price": 19.99,
        "title": "Sample Book Title",
        "image_url": "/book_covers/1.jpg"
      }
    ]
  }
}
```

### Error Response (401 Unauthorized)
```json
{
  "error": "Not authenticated"
}
```

## Create New Cart

Create a new empty cart for the current user. This is typically done automatically when needed.

**Endpoint**: `POST /carts`

### Headers
- `Cookie`: `_loverary_session=<session_token>`
- `X-CSRF-Token`: `<csrf_token>`
- `Content-Type`: `application/json`

### Success Response (201 Created)
```json
{
  "message": "Cart created",
  "cart": {
    "id": 124,
    "user_id": 1,
    "status": "active",
    "created_at": "2025-08-03T00:10:00.000Z",
    "updated_at": "2025-08-03T00:10:00.000Z",
    "cart_items": []
  }
}
```

### Error Response (401 Unauthorized)
```json
{
  "error": "Not authenticated"
}
```

## Add Items to Cart

Add one or more items to the user's cart. If no active cart exists, one will be created automatically.

**Endpoint**: `POST /carts/add`

### Headers
- `Content-Type`: `application/json`
- `Cookie`: `_loverary_session=<session_token>`
- `X-CSRF-Token`: `<csrf_token>`

### Request Body
```json
{
  "items": [
    {
      "book_id": 1,
      "quantity": 2,
      "price": 19.99
    },
    {
      "book_id": 3,
      "quantity": 1,
      "price": 24.99
    }
  ]
}
```

### Required Fields per Item
- `book_id`: Integer (ID of the book to add)
- `quantity`: Integer (number of copies, must be > 0 and <= available stock)
- `price`: Float (price per unit, must match current book price)

### Success Response (200 OK)
```json
{
  "message": "Items added to cart",
  "cart": {
    "id": 123,
    "user_id": 1,
    "status": "active",
    "created_at": "2025-08-03T00:00:00.000Z",
    "updated_at": "2025-08-03T00:15:00.000Z",
    "cart_items": [
      {
        "book_id": 1,
        "quantity": 2,
        "price": 19.99,
        "title": "Sample Book 1",
        "image_url": "/book_covers/1.jpg"
      },
      {
        "book_id": 3,
        "quantity": 1,
        "price": 24.99,
        "title": "Sample Book 3",
        "image_url": "/book_covers/3.jpg"
      }
    ],
    "item_count": 3,
    "subtotal": 64.97
  }
}
```

### Error Responses

#### 401 Unauthorized
```json
{
  "error": "Not authenticated"
}
```

#### 406 Not Acceptable (No valid items)
```json
{
  "message": "No valid items in request"
}
```

#### 422 Unprocessable Entity (Validation error)
```json
{
  "errors": {
    "items": [
      "Quantity must be greater than 0",
      "Price doesn't match current book price"
    ]
  }
}
```

## Update Cart Item Quantity

Update the quantity of a specific item in the cart. If quantity is set to 0, the item will be removed from the cart.

**Endpoint**: `PATCH /carts`

### Headers
- `Content-Type`: `application/json`
- `Cookie`: `_loverary_session=<session_token>`
- `X-CSRF-Token`: `<csrf_token>`

### Request Body
```json
{
  "book_id": 1,
  "quantity": 3
}
```

### Required Fields
- `book_id`: Integer (ID of the book to update)
- `quantity`: Integer (new quantity, must be >= 0 and <= available stock)

### Success Response (200 OK)
```json
{
  "message": "Cart updated",
  "cart": {
    "id": 123,
    "user_id": 1,
    "status": "active",
    "created_at": "2025-08-03T00:00:00.000Z",
    "updated_at": "2025-08-03T00:20:00.000Z",
    "cart_items": [
      {
        "book_id": 1,
        "quantity": 3,
        "price": 19.99,
        "title": "Sample Book 1",
        "image_url": "/book_covers/1.jpg"
      },
      {
        "book_id": 3,
        "quantity": 1,
        "price": 24.99,
        "title": "Sample Book 3",
        "image_url": "/book_covers/3.jpg"
      }
    ],
    "item_count": 4,
    "subtotal": 84.96
  }
}
```

### Error Responses

#### 401 Unauthorized
```json
{
  "error": "Not authenticated"
}
```

#### 404 Not Found (Item not in cart)
```json
{
  "error": "Item not found in cart"
}
```

#### 422 Unprocessable Entity (Validation error)
```json
{
  "errors": {
    "quantity": ["must be less than or equal to available stock (5)"]
  }
}
```

## Remove Item from Cart

Remove a specific item from the cart.

**Endpoint**: `DELETE /carts/remove/:book_id`

### Headers
- `Cookie`: `_loverary_session=<session_token>`
- `X-CSRF-Token`: `<csrf_token>`

### URL Parameters
- `book_id`: Integer (ID of the book to remove)

### Success Response (200 OK)
```json
{
  "message": "Item removed from cart",
  "cart": {
    "id": 123,
    "user_id": 1,
    "status": "active",
    "created_at": "2025-08-03T00:00:00.000Z",
    "updated_at": "2025-08-03T00:25:00.000Z",
    "cart_items": [
      {
        "book_id": 3,
        "quantity": 1,
        "price": 24.99,
        "title": "Sample Book 3",
        "image_url": "/book_covers/3.jpg"
      }
    ],
    "item_count": 1,
    "subtotal": 24.99
  }
}
```

### Error Responses

#### 401 Unauthorized
```json
{
  "error": "Not authenticated"
}
```

#### 404 Not Found (Item not in cart)
```json
{
  "error": "Item not found in cart"
}
```

#### 404 Not Found (Cart not found)
```json
{
  "error": "No active cart found"
}
```

## Clear Cart

Remove all items from the cart. The cart itself remains active but empty.

**Endpoint**: `DELETE /carts/clear`

### Headers
- `Cookie`: `_loverary_session=<session_token>`
- `X-CSRF-Token`: `<csrf_token>`

### Success Response (200 OK)
```json
{
  "message": "Cart cleared",
  "cart": {
    "id": 123,
    "user_id": 1,
    "status": "active",
    "created_at": "2025-08-03T00:00:00.000Z",
    "updated_at": "2025-08-03T00:30:00.000Z",
    "cart_items": [],
    "item_count": 0,
    "subtotal": 0.0
  }
}
```

### Error Response (401 Unauthorized)
```json
{
  "error": "Not authenticated"
}
```

## Checkout

Convert the current cart into an order. This will:
1. Validate all items in the cart
2. Check stock availability
3. Create an order with the current cart items
4. Clear the cart
5. Return the order details

**Endpoint**: `POST /carts/checkout`

### Headers
- `Cookie`: `_loverary_session=<session_token>`
- `X-CSRF-Token`: `<csrf_token>`
- `Content-Type`: `application/json`

### Request Body (Optional)
```json
{
  "shipping_address_id": 1,
  "billing_address_id": 2,
  "payment_method": "credit_card",
  "notes": "Leave at the front door"
}
```

### Success Response (201 Created)
```json
{
  "message": "Order created successfully",
  "order": {
    "id": 42,
    "user_id": 1,
    "status": "pending",
    "total_price": 64.97,
    "item_count": 3,
    "created_at": "2025-08-03T01:00:00.000Z",
    "order_items": [
      {
        "book_id": 1,
        "quantity": 2,
        "price": 19.99,
        "title": "Sample Book 1"
      },
      {
        "book_id": 3,
        "quantity": 1,
        "price": 24.99,
        "title": "Sample Book 3"
      }
    ]
  },
  "cart": {
    "id": 123,
    "status": "converted",
    "converted_at": "2025-08-03T01:00:00.000Z"
  }
}
```

### Error Responses

#### 400 Bad Request (Missing required fields)
```json
{
  "error": "Missing required shipping information"
}
```

#### 404 Not Found (Empty cart)
```json
{
  "error": "Cannot checkout an empty cart"
}
```

#### 422 Unprocessable Entity (Validation error)
```json
{
  "error": "Insufficient stock for item: Sample Book 1 (requested: 2, available: 1)",
  "item_id": 1,
  "requested_quantity": 2,
  "available_quantity": 1
}
```

#### 409 Conflict (Concurrent modification)
```json
{
  "error": "Cart was modified during checkout. Please review and try again."
}
```

## Error Handling

### Common Error Responses

**401 Unauthorized**
```json
{
  "error": "Please log in"
}
```

**404 Not Found**
```json
{
  "message": "item not found in cart"
}
```

**406 Not Acceptable**
```json
{
  "message": "no valid items"
}
```

## Important Notes
1. The cart is stored in the user's session and requires authentication.
2. All prices should be sent as floats with exactly 2 decimal places.
3. The cart will automatically validate book availability (stock) before adding items.
4. After successful checkout, the cart is automatically cleared.
5. The `count` in responses represents the total number of items (sum of all quantities).
