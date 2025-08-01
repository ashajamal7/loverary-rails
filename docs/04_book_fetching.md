# Book Fetching API Documentation

This document explains how to retrieve, filter, sort, and paginate books from the Loverary API. The API provides comprehensive access to the book catalog with various query parameters for fine-grained control over the results.

## Authentication

Most book endpoints are publicly accessible and do not require authentication. However, some features like adding reviews or managing favorites require authentication.

## Table of Contents
1. [Get All Books](#get-all-books)
2. [Get Single Book](#get-single-book)
3. [Filtering Books](#filtering-books)
   - [By Availability](#by-availability)
   - [By Author](#by-author)
   - [By Category](#by-category)
   - [By Price Range](#by-price-range)
   - [By Search Query](#by-search-query)
4. [Sorting](#sorting)
5. [Pagination](#pagination)
6. [Response Format](#response-format)
7. [Error Handling](#error-handling)
8. [Frontend Implementation Guide](#frontend-implementation-guide)

## Get All Books

Retrieve a paginated list of books with optional filtering and sorting.

**Endpoint**: `GET /books`

### Query Parameters

#### Pagination
- `page`: Integer (page number for pagination, default: 1)
- `per_page`: Integer (number of items per page, default: 10, max: 100)

#### Filters
- `in_stock`: Boolean (filter books that are in stock)
- `author_id`: Integer (filter by author ID)
- `category_id`: Integer (filter by category ID)
- `min_price`: Decimal (minimum price)
- `max_price`: Decimal (maximum price)
- `q`: String (search query for book title or author name)

#### Sorting
- `sort`: String (field to sort by, e.g., `title`, `price`, `created_at`)
- `order`: String (sort direction: `asc` or `desc`, default: `asc`)

## Filtering Books

### By Availability

Filter books by their stock availability.

**Example**: 
```
GET /books?in_stock=true
```

**Frontend Implementation**:
```javascript
// When "In Stock" checkbox is toggled
function handleStockFilter(checked) {
  const params = new URLSearchParams(window.location.search);
  if (checked) {
    params.set('in_stock', 'true');
  } else {
    params.delete('in_stock');
  }
  // Update URL and fetch books
  updateBooks(params);
}
```

### By Author

Filter books by a specific author.

**Example**: 
```
GET /books?author_id=1
```

**Frontend Implementation**:
```javascript
// When an author is selected from a dropdown
function handleAuthorFilter(authorId) {
  const params = new URLSearchParams(window.location.search);
  if (authorId) {
    params.set('author_id', authorId);
  } else {
    params.delete('author_id');
  }
  // Reset to first page when changing filters
  params.set('page', '1');
  updateBooks(params);
}
```

### By Category

Filter books by a specific category.

**Example**: 
```
GET /books?category_id=2
```

**Frontend Implementation**:
```javascript
// When a category is selected
function handleCategoryFilter(categoryId) {
  const params = new URLSearchParams(window.location.search);
  if (categoryId) {
    params.set('category_id', categoryId);
  } else {
    params.delete('category_id');
  }
  params.set('page', '1');
  updateBooks(params);
}
```

### By Price Range

Filter books within a specific price range.

**Example**: 
```
GET /books?min_price=10&max_price=50
```

**Frontend Implementation**:
```javascript
// When price range is applied
function handlePriceFilter(minPrice, maxPrice) {
  const params = new URLSearchParams(window.location.search);
  
  if (minPrice) {
    params.set('min_price', minPrice);
  } else {
    params.delete('min_price');
  }
  
  if (maxPrice) {
    params.set('max_price', maxPrice);
  } else {
    params.delete('max_price');
  }
  
  params.set('page', '1');
  updateBooks(params);
}
```

### By Search Query

Search books by title or author name.

**Example**: 
```
GET /books?q=harry+potter
```

**Frontend Implementation**:
```javascript
// When search form is submitted
function handleSearch(query) {
  const params = new URLSearchParams(window.location.search);
  
  if (query.trim()) {
    params.set('q', query.trim());
  } else {
    params.delete('q');
  }
  
  params.set('page', '1');
  updateBooks(params);
}
```

## Sorting

Sort books by different fields in ascending or descending order.

**Examples**:
- Sort by price (low to high): `GET /books?sort=price&order=asc`
- Sort by newest first: `GET /books?sort=created_at&order=desc`
- Sort by title (A-Z): `GET /books?sort=title&order=asc`

**Frontend Implementation**:
```javascript
// When sort option is changed
function handleSortChange(sortField, sortOrder) {
  const params = new URLSearchParams(window.location.search);
  
  params.set('sort', sortField);
  params.set('order', sortOrder);
  
  updateBooks(params);
}

// Example sort dropdown in your UI
// <select onChange={(e) => handleSortChange('price', e.target.value)}>
//   <option value="asc">Price: Low to High</option>
//   <option value="desc">Price: High to Low</option>
//   <option value="title_asc">Title: A-Z</option>
//   <option value="title_desc">Title: Z-A</option>
//   <option value="newest">Newest First</option>
// </select>
```

## Pagination

### Headers
- `Accept`: `application/json`
- `Content-Type`: `application/json` (for POST/PUT/PATCH requests)

### Authentication
- Not required for read operations

### Success Response (200 OK)
```json
{
  "books": [
    {
      "id": 1,
      "title": "The Great Gatsby",
      "isbn": "9780743273565",
      "language": "English",
      "page_count": 180,
      "stock": 15,
      "price": 12.99,
      "author_id": 1,
      "summary": "A story of decadence and excess...",
      "published_date": "1925-04-10",
      "edition": "1st",
      "cover_url": "http://example.com/covers/great-gatsby.jpg"
    },
    {
      "id": 2,
      "title": "To Kill a Mockingbird",
      "isbn": "9780061120084",
      "language": "English",
      "page_count": 281,
      "stock": 8,
      "price": 10.99,
      "author_id": 2,
      "summary": "A story of racial injustice...",
      "published_date": "1960-07-11",
      "edition": "1st",
      "cover_url": "http://example.com/covers/mockingbird.jpg"
    }
  ],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 5,
    "total_count": 50
  }
}
```

## Get Single Book

Retrieve detailed information about a specific book.

**Endpoint**: `GET /books/:id`

### URL Parameters
- `id`: Integer (ID of the book to retrieve)

### Headers
- `Accept`: `application/json`

### Authentication
- Not required

### Success Response (200 OK)
```json
{
  "id": 1,
  "title": "The Great Gatsby",
  "isbn": "9780743273565",
  "language": "English",
  "page_count": 180,
  "stock": 15,
  "price": 12.99,
  "author_id": 1,
  "summary": "A story of decadence and excess...",
  "published_date": "1925-04-10",
  "edition": "1st",
  "cover_url": "http://example.com/covers/great-gatsby.jpg"
}
```

## Filtering Books

### By Availability

Filter books by their stock status.

**Endpoint**: `GET /books?in_stock=true`

#### Query Parameters
- `in_stock`: Boolean (true = only books with stock > 0)

#### Example Request
```http
GET /books?in_stock=true
```

### By Author

Filter books by author ID.

**Endpoint**: `GET /books?author_id=3`

#### Query Parameters
- `author_id`: Integer (ID of the author)

#### Example Request
```http
GET /books?author_id=3
```

### By Category

Filter books by category ID.

**Endpoint**: `GET /books?category_id=5`

#### Query Parameters
- `category_id`: Integer (ID of the category)

#### Example Request
```http
GET /books?category_id=5
```

#### Notes:
- Multiple filters can be combined, e.g., `/books?in_stock=true&category_id=5`
- The `in_stock` filter is particularly useful for ensuring only available books are displayed

## Response Format

## Error Handling

### Common Error Responses

| Status Code | Error Code | Description |
|-------------|------------|-------------|
| 400 | bad_request | Invalid request parameters |
| 401 | unauthorized | Authentication required |
| 403 | forbidden | Insufficient permissions |
| 404 | not_found | Resource not found |
| 422 | unprocessable_entity | Validation failed |
| 429 | too_many_requests | Rate limit exceeded |
| 500 | server_error | Internal server error |

### Example Error Response

```json
{
  "error": {
    "code": "not_found",
    "message": "Book not found",
    "details": "The requested book with ID 999 does not exist"
  }
}
```

### Frontend Error Handling Example

```javascript
async function fetchBooks() {
  try {
    const response = await fetch('/api/books');
    
    if (!response.ok) {
      const error = await response.json().catch(() => ({}));
      throw new Error(error.message || 'Failed to fetch books');
    }
    
    return await response.json();
  } catch (error) {
    console.error('Error fetching books:', error);
    // Show error message to user
    showNotification({
      type: 'error',
      message: error.message || 'An error occurred while fetching books'
    });
    throw error; // Re-throw to allow calling code to handle the error
  }
#### Book Not Found (404)
```json
{
  "error": "Book not found",
  "code": "not_found"
}
```

#### Invalid Parameters (400)
```json
{
  "error": "Invalid parameters",
  "code": "invalid_parameters",
  "details": {
    "per_page": ["must be less than or equal to 100"]
  }
}
```

## Best Practices

1. **Caching**: Consider implementing client-side caching for book data that doesn't change frequently
2. **Pagination**: Always implement pagination for lists to improve performance
3. **Error Handling**: Handle all possible error responses gracefully
4. **Rate Limiting**: Implement proper error handling for rate limit responses
5. **Image Handling**: Use appropriate image sizes and lazy loading for book covers
6. **Retry Logic**: Implement retry logic for failed requests with exponential backoff

## Versioning

API versioning is handled through the URL path (e.g., `/api/v1/books`). The current version is v1.

## Support

For additional support, please contact [support@loverary.com](mailto:support@loverary.com) or visit our [developer portal](https://developer.loverary.com).

## Important Notes
1. All prices are in the store's base currency (e.g., USD).
2. Stock levels are updated in real-time.
3. The `average_rating` is calculated based on user reviews (1-5 scale).
4. Image URLs are relative to the API base URL.
5. When including related resources, the response structure may change significantly.
6. Some filters can be combined for more specific queries.
7. The search is case-insensitive and performs partial matches on title, author, and description fields.
