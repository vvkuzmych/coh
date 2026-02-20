# Swagger API Documentation

OpenAPI/Swagger документація для API V1.

## Доступ до документації

### Swagger UI (Interactive)
```
http://localhost:3000/api-docs
```

Інтерактивна документація де можна:
- 📖 Переглядати всі endpoints
- 🧪 Тестувати API прямо з браузера
- 📋 Копіювати curl команди
- ✅ Валідувати запити та відповіді

### Swagger YAML (Raw)
```
http://localhost:3000/api-docs/v1/swagger.yaml
```

Raw OpenAPI специфікація в YAML форматі для:
- Імпорт в Postman
- Генерація клієнтів (codegen)
- CI/CD валідація

## Структура

```
swagger/
└── v1/
    └── swagger.yaml  # OpenAPI 3.0.1 specification
```

## API Endpoints

### GET /api/v1/documents
Список документів з pagination, filtering, sorting

**Query Parameters:**
- `page` - номер сторінки (default: 1)
- `per_page` - кількість на сторінці (max: 100, default: 20)
- `q` або `search` - пошук в title/content
- `status` - фільтр по статусу (draft/reviewed/signed/archived)
- `date_from` - фільтр від дати (ISO 8601)
- `date_to` - фільтр до дати (ISO 8601)
- `sort_by` - поле для сортування (created_at/title/status)
- `order` - напрямок (asc/desc)

**Response:**
```json
{
  "success": true,
  "data": [...],
  "meta": {
    "total_count": 150,
    "current_page": 1,
    "per_page": 20,
    "total_pages": 8
  }
}
```

### GET /api/v1/documents/:id
Отримати документ за ID

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "abc123",
    "type": "document",
    "attributes": {
      "title": "Contract",
      "content": "...",
      "status": "signed",
      "created_at": "2024-01-15T10:30:00Z"
    }
  },
  "meta": {}
}
```

## Використання в Postman

1. Відкрий Postman
2. Import → Link → `http://localhost:3000/api-docs/v1/swagger.yaml`
3. Створюється колекція з усіма endpoints

## Генерація клієнтів

```bash
# JavaScript/TypeScript client
npx @openapitools/openapi-generator-cli generate \
  -i http://localhost:3000/api-docs/v1/swagger.yaml \
  -g typescript-axios \
  -o ./generated/api-client

# Ruby client
openapi-generator generate \
  -i http://localhost:3000/api-docs/v1/swagger.yaml \
  -g ruby \
  -o ./generated/ruby-client
```

## Оновлення документації

Swagger файл: `swagger/v1/swagger.yaml`

Після змін в API:
1. Оновити `swagger/v1/swagger.yaml`
2. Перезапустити сервер
3. Перевірити http://localhost:3000/api-docs

## Корисні посилання

- Swagger UI: http://localhost:3000/api-docs
- OpenAPI Spec: https://swagger.io/specification/
- OpenAPI Generator: https://openapi-generator.tech/
