# Author API Documentation

This document explains how to retrieve author information from the Loverary API.

## Table of Contents
1. [Get All Authors](#get-all-authors)
2. [Get Single Author](#get-single-author)
3. [Get Author's Books](#get-authors-books)
4. [Filtering and Sorting](#filtering-and-sorting)
5. [Pagination](#pagination)
6. [Error Handling](#error-handling)

## Get All Authors

Retrieve a list of all authors.

**Endpoint**: `GET /authors`

### Query Parameters
- `sort`: String (sort order, see [Sorting](#sorting))
- `page`: Integer (page number for pagination, default: 1)
- `per_page`: Integer (number of items per page, default: 20, max: 100)

### Success Response (200 OK)
```json
{
  "authors": [
    {
      "id": 1,
      "name": "F. Scott Fitzgerald",
      "bio": "Francis Scott Key Fitzgerald was an American novelist, essayist, short story writer and screenwriter.",
      "birth_date": "1896-09-24",
      "death_date": "1940-12-21",
      "nationality": "American",
      "total_books": 5,
      "image_url": "/authors/fitzgerald.jpg"
    },
    {
      "id": 2,
      "name": "Harper Lee",
      "bio": "Nelle Harper Lee was an American novelist best known for her 1960 novel To Kill a Mockingbird.",
      "birth_date": "1926-04-28",
      "death_date": "2016-02-19",
      "nationality": "American",
      "total_books": 2,
      "image_url": "/authors/harper-lee.jpg"
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 3,
    "total_count": 54,
    "per_page": 20
  }
}
```

## Get Single Author

Retrieve detailed information about a specific author.

**Endpoint**: `GET /authors/:id`

### URL Parameters
- `id`: Integer (ID of the author to retrieve)

### Query Parameters
- `include`: String (comma-separated list of related resources to include, e.g., `books`)

### Success Response (200 OK)
```json
{
  "id": 1,
  "name": "F. Scott Fitzgerald",
  "bio": "Francis Scott Key Fitzgerald was an American novelist, essayist, short story writer and screenwriter. He was best known for his novels depicting the flamboyance and excess of the Jazz Age.",
  "birth_date": "1896-09-24",
  "birth_place": "St. Paul, Minnesota, U.S.",
  "death_date": "1940-12-21",
  "death_place": "Hollywood, California, U.S.",
  "nationality": "American",
  "website": "https://fscottfitzgeraldsociety.org/",
  "image_url": "/authors/fitzgerald.jpg",
  "total_books": 5,
  "books": [
    {
      "id": 1,
      "title": "The Great Gatsby",
      "published_year": 1925,
      "cover_url": "/covers/great-gatsby.jpg",
      "average_rating": 4.2
    },
    {
      "id": 2,
      "title": "Tender Is the Night",
      "published_year": 1934,
      "cover_url": "/covers/tender-night.jpg",
      "average_rating": 4.0
    }
  ]
}
```

## Get Author's Books

Retrieve all books by a specific author.

**Endpoint**: `GET /authors/:id/books`

### URL Parameters
- `id`: Integer (ID of the author)

### Query Parameters
- `sort`: String (sort order, see [Sorting](#sorting))
- `page`: Integer (page number for pagination, default: 1)
- `per_page`: Integer (number of items per page, default: 20, max: 100)

### Success Response (200 OK)
```json
{
  "books": [
    {
      "id": 1,
      "title": "The Great Gatsby",
      "published_year": 1925,
      "cover_url": "/covers/great-gatsby.jpg",
      "price": 12.99,
      "average_rating": 4.2,
      "review_count": 128,
      "in_stock": true
    },
    {
      "id": 2,
      "title": "Tender Is the Night",
      "published_year": 1934,
      "cover_url": "/covers/tender-night.jpg",
      "price": 14.99,
      "average_rating": 4.0,
      "review_count": 85,
      "in_stock": true
    }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 1,
    "total_count": 2,
    "per_page": 20
  }
}
```

## Filtering and Sorting

### Available Sort Options
- `name_asc`: Sort by name (A-Z)
- `name_desc`: Sort by name (Z-A)
- `birth_date_asc`: Sort by birth date (oldest first)
- `birth_date_desc`: Sort by birth date (newest first)
- `books_count`: Sort by number of books (highest first)

**Example**: `GET /authors?sort=books_count`

## Pagination

All list endpoints support pagination.

**Example**: `GET /authors?page=2&per_page=10`

### Response Metadata
```json
{
  "authors": [...],
  "meta": {
    "current_page": 2,
    "total_pages": 6,
    "total_count": 54,
    "per_page": 10
  }
}
```

## Error Handling

### Common Error Responses

**404 Not Found**
```json
{
  "error": "Author not found"
}
```

**400 Bad Request**
```json
{
  "error": "Invalid sort parameter"
}
```

## Important Notes
1. Author images are served as URLs to image files.
2. The `total_books` field represents the count of all books by this author in the system.
3. When including books with an author, the response will include an array of simplified book objects.
4. All dates are returned in ISO 8601 format (YYYY-MM-DD).
5. Some fields may be null if the information is not available in the database.
6. The API supports filtering authors by book count, nationality, and other criteria using query parameters.
