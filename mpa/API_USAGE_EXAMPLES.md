# API Usage Examples

Quick reference for using the API endpoints.

## Base URL
```
Development: http://localhost:3000/api/v1
Production: https://your-domain.com/api/v1
```

## Endpoints

### 1. List Documents (with pagination, filtering, sorting)

```bash
# Basic request
GET /api/v1/documents

# With pagination
GET /api/v1/documents?page=2&per_page=20

# With search
GET /api/v1/documents?q=contract

# With status filter
GET /api/v1/documents?status=signed

# With sorting
GET /api/v1/documents?sort_by=title&order=asc

# Combined filters
GET /api/v1/documents?q=payment&status=signed&page=1&per_page=10&sort_by=_score&order=desc
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "123",
      "type": "document",
      "attributes": {
        "title": "Contract Agreement",
        "content": "...",
        "status": "signed",
        "created_at": "2024-01-15T10:30:00Z"
      }
    }
  ],
  "meta": {
    "total_count": 150,
    "current_page": 1,
    "per_page": 20,
    "total_pages": 8
  }
}
```

### 2. Get Single Document

```bash
GET /api/v1/documents/:id
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "123",
    "type": "document",
    "attributes": {
      "title": "Contract Agreement",
      "content": "Full document content...",
      "status": "signed",
      "created_at": "2024-01-15T10:30:00Z"
    }
  },
  "meta": {}
}
```

## Query Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `page` | integer | Page number (default: 1) | `?page=2` |
| `per_page` | integer | Items per page (max: 100, default: 20) | `?per_page=50` |
| `q` or `search` | string | Search in title/content | `?q=contract` |
| `status` | string | Filter by status (draft/reviewed/signed/archived) | `?status=signed` |
| `sort_by` | string | Sort field (_score/title/status) | `?sort_by=title` |
| `order` | string | Sort direction (asc/desc) | `?order=asc` |

## Response Format

### Success (2xx)
```json
{
  "success": true,
  "data": { ... },
  "meta": { ... }
}
```

### Error (4xx, 5xx)
```json
{
  "success": false,
  "error": {
    "message": "Document not found",
    "details": []
  }
}
```

## HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request succeeded |
| 404 | Not Found - Resource doesn't exist |
| 422 | Unprocessable Entity - Validation error |
| 500 | Internal Server Error - Server error |

## cURL Examples

```bash
# List documents
curl "http://localhost:3000/api/v1/documents?page=1&per_page=10"

# Search documents
curl "http://localhost:3000/api/v1/documents?q=contract&status=signed"

# Get single document
curl "http://localhost:3000/api/v1/documents/abc123"

# With headers
curl -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     "http://localhost:3000/api/v1/documents"
```

## JavaScript/React Examples

```javascript
// Fetch documents
const fetchDocuments = async (params = {}) => {
  const queryString = new URLSearchParams(params).toString();
  const response = await fetch(`/api/v1/documents?${queryString}`);
  const data = await response.json();
  
  if (data.success) {
    return data.data;
  } else {
    throw new Error(data.error.message);
  }
};

// Usage
const documents = await fetchDocuments({
  page: 1,
  per_page: 20,
  q: 'contract',
  status: 'signed',
  sort_by: '_score',
  order: 'desc'
});

// Fetch single document
const fetchDocument = async (id) => {
  const response = await fetch(`/api/v1/documents/${id}`);
  const data = await response.json();
  
  if (data.success) {
    return data.data;
  } else {
    throw new Error(data.error.message);
  }
};
```
