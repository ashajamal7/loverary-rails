# Order Functionality API Documentation

This document explains how to manage orders with the Loverary API.

## Table of Contents
1. [Get All Orders](#get-all-orders)
2. [Get Single Order](#get-single-order)
3. [Order Status Flow](#order-status-flow)
4. [Error Handling](#error-handling)

## Authentication
All order endpoints require authentication. Include the session cookie in your requests (handled automatically by browsers).

## Get All Orders

Retrieve a list of all orders for the authenticated user.

**Endpoint**: `GET /orders`

### Headers
- `Cookie`: `_loverary_session=<session_token>`

### Success Response (200 OK)
```json
[
  {
    "id": 42,
    "user_id": 1,
    "status": "completed",
    "total_price": 64.97,
    "created_at": "2025-08-01T20:15:30.000Z",
    "updated_at": "2025-08-01T20:15:30.000Z",
    "order_items": [
      {
        "id": 101,
        "book_id": 1,
        "quantity": 2,
        "price": 19.99,
        "book_title": "Sample Book 1"
      },
      {
        "id": 102,
        "book_id": 3,
        "quantity": 1,
        "price": 24.99,
        "book_title": "Sample Book 3"
      }
    ]
  },
  {
    "id": 43,
    "user_id": 1,
    "status": "pending",
    "total_price": 34.98,
    "created_at": "2025-08-02T10:30:45.000Z",
    "updated_at": "2025-08-02T10:30:45.000Z",
    "order_items": [
      {
        "id": 103,
        "book_id": 5,
        "quantity": 1,
        "price": 34.98,
        "book_title": "Sample Book 5"
      }
    ]
  }
]
```

## Get Single Order

Retrieve detailed information about a specific order.

**Endpoint**: `GET /orders/:id`

### URL Parameters
- `id`: Integer (ID of the order to retrieve)

### Headers
- `Cookie`: `_loverary_session=<session_token>`

### Success Response (200 OK)
```json
{
  "id": 42,
  "user_id": 1,
  "status": "completed",
  "total_price": 64.97,
  "created_at": "2025-08-01T20:15:30.000Z",
  "updated_at": "2025-08-01T20:15:30.000Z",
  "order_items": [
    {
      "id": 101,
      "book_id": 1,
      "quantity": 2,
      "price": 19.99,
      "book_title": "Sample Book 1",
      "book_cover_url": "/covers/sample-book-1.jpg"
    },
    {
      "id": 102,
      "book_id": 3,
      "quantity": 1,
      "price": 24.99,
      "book_title": "Sample Book 3",
      "book_cover_url": "/covers/sample-book-3.jpg"
    }
  ],
  "shipping_address": {
    "id": 7,
    "full_name": "John Doe",
    "street": "123 Main St",
    "city": "New York",
    "state": "NY",
    "postal_code": "10001",
    "country": "USA"
  },
  "tracking_info": {
    "tracking_number": "1Z999AA1234567890",
    "carrier": "UPS",
    "status": "delivered",
    "estimated_delivery": "2025-08-05T23:59:59.000Z"
  }
}
```

### Error Response (404 Not Found)
```json
{
  "error": "Order not found"
}
```

### Error Response (403 Forbidden)
```json
{
  "error": "Not authorized to view this order"
}
```

## Order Status Flow

Orders follow this status flow:
1. `pending`: Order created but payment not yet processed
2. `paid`: Payment received, order being prepared
3. `shipped`: Order has been shipped
4. `delivered`: Order has been delivered
5. `cancelled`: Order has been cancelled
6. `refunded`: Order has been refunded

## Error Handling

### Common Error Responses

**401 Unauthorized**
```json
{
  "error": "Please log in"
}
```

**403 Forbidden**
```json
{
  "error": "Not authorized to view this order"
}
```

**404 Not Found**
```json
{
  "error": "Order not found"
}
```

**422 Unprocessable Entity**
```json
{
  "errors": [
    "Status is not included in the list"
  ]
}
```

## Important Notes
1. Users can only view their own orders.
2. Order history includes all past and current orders.
3. The `order_items` array includes details about each book in the order.
4. Shipping and tracking information is included when available.
5. Prices are always in the store's base currency (e.g., USD).
