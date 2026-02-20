# Fullstack Rails + React - Job Requirements 💼

Детальний розбір вимог вакансії Fullstack Developer (Ruby on Rails + React/TypeScript).

---

## 📋 Job Description

### Position: Fullstack Developer
**Stack:** Ruby on Rails (Backend) + React/TypeScript (Frontend)  
**Focus:** REST API + Elasticsearch + Modern UI

---

## 🔴 BACKEND REQUIREMENTS (Ruby on Rails)

### 1. **REST API Design** ⭐⭐⭐ (Critical)

**Що потрібно:**
- Створення REST endpoints (GET, POST, PUT, PATCH, DELETE)
- API versioning (`/api/v1/...`, `/api/v2/...`)
- Pagination (offset-based, cursor-based)
- Filtering (по полях, статусах, датах)
- Sorting (ASC/DESC, multiple fields)
- Consistent response format

**Приклади:**
```ruby
# Versioning
namespace :api do
  namespace :v1 do
    resources :documents
  end
end

# Response format
{
  success: true,
  data: [...],
  meta: {
    total: 100,
    page: 1,
    per_page: 20
  }
}

# HTTP status codes
200 OK
201 Created
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
422 Unprocessable Entity
500 Internal Server Error
```

---

### 2. **Ruby on Rails** ⭐⭐⭐ (Critical)

**Що потрібно:**
- Controllers (thin controllers pattern)
- Service objects (business logic)
- ActiveRecord (models, associations, validations)
- Routes (resources, namespace)
- Concerns (shared behavior)
- Background jobs (Sidekiq)
- Middleware

**Приклади:**
```ruby
# Thin Controller
class Api::DocumentsController < ApplicationController
  def index
    result = DocumentSearcher.new(params).call
    render json: { success: true, data: result }
  end
end

# Service Object
class DocumentSearcher
  def initialize(params)
    @query = params[:q]
    @status = params[:status]
  end
  
  def call
    # Business logic here
  end
end

# Model with associations
class Document < ApplicationRecord
  belongs_to :user
  has_many :comments
  
  validates :title, presence: true
  enum status: { draft: 0, published: 1 }
end
```

---

### 3. **Database & Performance** ⭐⭐⭐ (Critical)

**Що потрібно:**
- SQL query optimization
- N+1 query problem (`includes`, `preload`, `eager_load`)
- Database indexes
- Query scopes
- Batch processing (`find_each`)
- Connection pooling

**Приклади:**
```ruby
# ❌ N+1 Problem
User.all.each { |u| u.posts.count }  # 1 + N queries

# ✅ Solution
User.includes(:posts).each { |u| u.posts.count }  # 2 queries

# Indexes
add_index :users, :email, unique: true
add_index :documents, [:user_id, :status]

# Scopes
class Document < ApplicationRecord
  scope :published, -> { where(status: :published) }
  scope :recent, -> { order(created_at: :desc) }
end

# Batch processing
User.find_each(batch_size: 1000) do |user|
  # Process one by one
end
```

---

### 4. **Elasticsearch/OpenSearch** ⭐⭐ (Important)

**Що потрібно:**
- Search queries (match, multi_match, bool)
- Filters (term, range, exists)
- Sorting (по полях, relevance)
- Aggregations (buckets, metrics)
- Pagination (from, size)
- Performance tuning

**Приклади:**
```ruby
# Search with filters
OPENSEARCH_CLIENT.search(
  index: 'documents',
  body: {
    query: {
      bool: {
        must: [
          { multi_match: { query: 'contract', fields: ['title', 'content'] } }
        ],
        filter: [
          { term: { status: 'published' } },
          { range: { created_at: { gte: '2024-01-01' } } }
        ]
      }
    },
    sort: [{ created_at: { order: 'desc' } }],
    from: 0,
    size: 20,
    aggs: {
      status_counts: {
        terms: { field: 'status' }
      }
    }
  }
)
```

---

### 5. **Authorization & Security** ⭐⭐ (Important)

**Що потрібно:**
- Role-based access control (RBAC)
- Domain-based permissions
- Authorization checks (`before_action`)
- SQL injection prevention
- CSRF protection
- Strong parameters
- Authentication (JWT, sessions)

**Приклади:**
```ruby
# Authorization
class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_document, only: [:show, :update, :destroy]
  
  private
  
  def authorize_document
    @document = current_user.documents.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Forbidden' }, status: :forbidden
  end
end

# Pundit (authorization gem)
class DocumentPolicy
  def update?
    user.admin? || record.user_id == user.id
  end
end

# SQL injection prevention
# ❌ BAD
User.where("email = '#{params[:email]}'")

# ✅ GOOD
User.where("email = ?", params[:email])
User.where(email: params[:email])

# Strong parameters
params.require(:document).permit(:title, :content, :status)
```

---

### 6. **API Documentation** ⭐⭐ (Important)

**Що потрібно:**
- OpenAPI/Swagger specification
- JSON schemas
- Request/response examples
- Versioning documentation
- Error codes documentation

**Приклади:**
```yaml
# openapi.yaml
openapi: 3.0.0
info:
  title: Documents API
  version: 1.0.0

paths:
  /api/v1/documents:
    get:
      summary: List documents
      parameters:
        - name: page
          in: query
          schema:
            type: integer
        - name: status
          in: query
          schema:
            type: string
            enum: [draft, published]
      responses:
        200:
          description: Success
          content:
            application/json:
              schema:
                type: object
                properties:
                  success:
                    type: boolean
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/Document'
```

---

### 7. **Testing** ⭐⭐⭐ (Critical)

**Що потрібно:**
- RSpec (unit tests, integration tests)
- FactoryBot (test data)
- Request specs (API testing)
- Service specs
- Mocking/stubbing

**Приклади:**
```ruby
# RSpec request spec
RSpec.describe "Api::Documents", type: :request do
  describe "GET /api/documents" do
    let!(:documents) { create_list(:document, 3) }
    
    it "returns documents" do
      get "/api/documents"
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to be true
      expect(json['data'].length).to eq(3)
    end
  end
  
  describe "GET /api/documents/:id" do
    let(:document) { create(:document) }
    
    it "returns document" do
      get "/api/documents/#{document.id}"
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['data']['title']).to eq(document.title)
    end
    
    it "returns 404 for missing document" do
      get "/api/documents/invalid-id"
      
      expect(response).to have_http_status(:not_found)
    end
  end
end

# Service spec
RSpec.describe DocumentSearcher do
  describe "#call" do
    it "searches documents" do
      result = described_class.new(query: 'test').call
      expect(result[:documents]).to be_an(Array)
    end
  end
end
```

---

## 🔵 FRONTEND REQUIREMENTS (React + TypeScript)

### 1. **React + TypeScript** ⭐⭐⭐ (Critical)

**Що потрібно:**
- Functional components з hooks
- TypeScript interfaces для props/state/API
- State management (`useState`, `useReducer`, `useContext`)
- Side effects (`useEffect`, cleanup)
- Performance (`useMemo`, `useCallback`)

**Приклади:**
```typescript
// Component with types
interface Document {
  id: string;
  title: string;
  status: 'draft' | 'published';
}

interface DocumentListProps {
  userId: number;
  onSelect?: (doc: Document) => void;
}

const DocumentList: React.FC<DocumentListProps> = ({ userId, onSelect }) => {
  const [documents, setDocuments] = useState<Document[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  
  useEffect(() => {
    const controller = new AbortController();
    
    const fetchDocs = async () => {
      const response = await fetch(`/api/documents?user_id=${userId}`, {
        signal: controller.signal
      });
      const data: ApiResponse<Document[]> = await response.json();
      setDocuments(data.data);
    };
    
    fetchDocs();
    
    return () => controller.abort();
  }, [userId]);
  
  return (
    <div>
      {documents.map(doc => (
        <div key={doc.id} onClick={() => onSelect?.(doc)}>
          {doc.title}
        </div>
      ))}
    </div>
  );
};
```

---

### 2. **REST API Integration** ⭐⭐⭐ (Critical)

**Що потрібно:**
- Async/await з fetch або axios
- TypeScript для requests/responses
- Error handling
- Loading states
- Retry logic
- Request cancellation (AbortController)

**Приклади:**
```typescript
// API types
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  meta?: {
    total: number;
    page: number;
  };
}

// API service
class DocumentsAPI {
  static async getAll(params: SearchParams): Promise<Document[]> {
    const response = await fetch(`/api/documents?${new URLSearchParams(params)}`);
    
    if (!response.ok) {
      throw new Error(`API error: ${response.status}`);
    }
    
    const data: ApiResponse<Document[]> = await response.json();
    return data.data || [];
  }
  
  static async getById(id: string): Promise<Document> {
    const response = await fetch(`/api/documents/${id}`);
    const data: ApiResponse<Document> = await response.json();
    
    if (!data.success) {
      throw new Error(data.error || 'Failed to fetch');
    }
    
    return data.data!;
  }
}
```

---

### 3. **Data Tables** ⭐⭐ (Important)

**Що потрібно:**
- Pagination (client/server-side)
- Sorting (по колонках)
- Filtering (input fields, dropdowns)
- Search (real-time або on submit)
- Loading states
- Empty states

**Приклади:**
```typescript
interface TableProps {
  data: Document[];
  page: number;
  totalPages: number;
  onPageChange: (page: number) => void;
  onSort: (field: string) => void;
  onFilter: (filters: Filters) => void;
}

const DataTable: React.FC<TableProps> = ({
  data, page, totalPages, onPageChange, onSort, onFilter
}) => {
  return (
    <div>
      {/* Filters */}
      <input onChange={(e) => onFilter({ search: e.target.value })} />
      
      {/* Table */}
      <table>
        <thead>
          <tr>
            <th onClick={() => onSort('title')}>Title ↕</th>
            <th onClick={() => onSort('status')}>Status ↕</th>
          </tr>
        </thead>
        <tbody>
          {data.map(doc => (
            <tr key={doc.id}>
              <td>{doc.title}</td>
              <td>{doc.status}</td>
            </tr>
          ))}
        </tbody>
      </table>
      
      {/* Pagination */}
      <div>
        <button onClick={() => onPageChange(page - 1)} disabled={page === 1}>
          Previous
        </button>
        <span>Page {page} of {totalPages}</span>
        <button onClick={() => onPageChange(page + 1)} disabled={page === totalPages}>
          Next
        </button>
      </div>
    </div>
  );
};
```

---

### 4. **HTML/CSS/JS Fundamentals** ⭐⭐⭐ (Critical)

**Що потрібно:**
- Semantic HTML5 (header, nav, main, article, section)
- CSS Flexbox та Grid
- Responsive design (media queries)
- CSS modules або styled-components
- JavaScript ES6+ (destructuring, spread, async/await)

**Приклади:**
```css
/* Flexbox */
.container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}

/* Grid */
.documents-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 24px;
}

/* Responsive */
@media (max-width: 768px) {
  .documents-grid {
    grid-template-columns: 1fr;
  }
}
```

```typescript
// ES6+ features
const { title, status } = document;  // Destructuring
const newDocs = [...oldDocs, newDoc];  // Spread
const filtered = docs.filter(d => d.status === 'published');  // Arrow functions
```

---

### 5. **Testing** ⭐⭐ (Important)

**Що потрібно:**
- Jest (unit tests)
- React Testing Library
- Component testing
- API mocking
- E2E testing (Cypress)

**Приклади:**
```typescript
// Jest + React Testing Library
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import DocumentList from './DocumentList';

describe('DocumentList', () => {
  it('renders documents', async () => {
    // Mock API
    global.fetch = jest.fn(() =>
      Promise.resolve({
        json: () => Promise.resolve({
          success: true,
          data: [{ id: '1', title: 'Test Doc' }]
        })
      })
    );
    
    render(<DocumentList userId={1} />);
    
    await waitFor(() => {
      expect(screen.getByText('Test Doc')).toBeInTheDocument();
    });
  });
  
  it('handles click events', async () => {
    const onSelect = jest.fn();
    render(<DocumentList userId={1} onSelect={onSelect} />);
    
    const doc = await screen.findByText('Test Doc');
    await userEvent.click(doc);
    
    expect(onSelect).toHaveBeenCalledWith({ id: '1', title: 'Test Doc' });
  });
});

// Cypress E2E
describe('Documents Page', () => {
  it('loads and displays documents', () => {
    cy.visit('/documents');
    cy.contains('Documents').should('be.visible');
    cy.get('.document-card').should('have.length.at.least', 1);
  });
  
  it('filters documents by status', () => {
    cy.visit('/documents');
    cy.get('[data-testid="status-filter"]').select('published');
    cy.get('.document-card').each($card => {
      cy.wrap($card).should('contain', 'PUBLISHED');
    });
  });
});
```

---

### 6. **Monorepo & Module Federation** ⭐ (Nice to have)

**Що потрібно:**
- Monorepo structure (Yarn workspaces, npm workspaces)
- Module federation (Webpack 5)
- Micro Frontends pattern
- Shared components/types
- Independent deployments

**Приклади:**
```
monorepo/
├── packages/
│   ├── api-client/         # Shared API client
│   │   ├── src/
│   │   │   └── documents.ts
│   │   └── package.json
│   ├── ui-components/      # Shared UI components
│   │   ├── src/
│   │   │   └── Button.tsx
│   │   └── package.json
│   └── types/              # Shared TypeScript types
│       ├── src/
│       │   └── document.ts
│       └── package.json
├── apps/
│   ├── admin/              # Admin app
│   ├── client/             # Client app
│   └── mobile/             # Mobile app
└── package.json            # Root package.json
```

---

## 🟢 KEY SKILLS SUMMARY

### Must Have (⭐⭐⭐):
| Skill | Backend | Frontend |
|-------|---------|----------|
| **Framework** | Ruby on Rails | React + TypeScript |
| **API** | REST design, versioning | fetch, async state |
| **Data** | SQL, N+1, indexes | Tables, pagination, filtering |
| **Testing** | RSpec (unit, integration) | Jest, React Testing Library |
| **Performance** | Query optimization | Component optimization |

### Should Have (⭐⭐):
| Skill | Backend | Frontend |
|-------|---------|----------|
| **Search** | Elasticsearch/OpenSearch | Search UI, filters |
| **Architecture** | Service objects, thin controllers | Component structure |
| **Security** | Authorization, permissions | CSRF, XSS prevention |
| **Docs** | OpenAPI/Swagger | Component documentation |

### Nice to Have (⭐):
| Skill | Backend | Frontend |
|-------|---------|----------|
| **Advanced** | Background jobs, caching | Monorepo, Module Federation |
| **Tools** | Docker, Redis | Webpack, Vite |
| **Testing** | Performance testing | E2E (Cypress) |

---

## 📚 Learning Path

### 1. Core Skills (Обов'язково):
- [ ] **Rails REST API** - Controllers, Routes, Serializers
- [ ] **React + TypeScript** - Components, Hooks, Types
- [ ] **Database optimization** - N+1, includes, indexes
- [ ] **Testing** - RSpec, Jest, React Testing Library
- [ ] **API design** - Versioning, pagination, filtering

### 2. Important Skills (Дуже бажано):
- [ ] **Elasticsearch** - Search, filters, aggregations
- [ ] **Service objects** - Thin controllers pattern
- [ ] **Authorization** - Permissions, RBAC
- [ ] **OpenAPI** - API documentation
- [ ] **Performance** - Caching, query optimization

### 3. Nice to Have (Бонус):
- [ ] **Monorepo** - Multi-app structure
- [ ] **Module Federation** - Micro Frontends
- [ ] **Cypress** - E2E testing
- [ ] **Background jobs** - Sidekiq, delayed_job
- [ ] **Docker** - Containerization

---

## ✅ Що ти вже знаєш (З нашої роботи):

### Backend ✅:
- ✅ REST API endpoints (`Api::DocumentsController`)
- ✅ Service objects (`DocumentSearcher`, `DocumentFetcher`)
- ✅ Thin controllers pattern
- ✅ OpenSearch integration (search, filters, aggregations)
- ✅ Error handling та custom exceptions
- ✅ RSpec testing (services, controllers)

### Frontend ✅:
- ✅ React + TypeScript (`DocumentShow.tsx`, `DocumentsList.tsx`)
- ✅ TypeScript interfaces для API responses
- ✅ Fetch з async/await
- ✅ Loading/error states
- ✅ CSS modules (окремі .css файли)
- ✅ Component structure

### Fullstack ✅:
- ✅ Повна інтеграція Rails + React + OpenSearch
- ✅ TypeScript types end-to-end
- ✅ Request deduplication
- ✅ Performance optimization

### Progress: ~70% ✅

---

## 📖 Що вивчити додатково:

### 1. **OpenAPI/Swagger** (High Priority)
- Написання OpenAPI specs
- Автогенерація документації
- Tools: `rswag` gem для Rails

### 2. **Jest Testing** (High Priority)
```bash
npm install --save-dev jest @testing-library/react @testing-library/jest-dom
```

### 3. **Cypress E2E** (Medium Priority)
```bash
npm install --save-dev cypress
npx cypress open
```

### 4. **Authorization** (High Priority)
- Pundit gem
- Role-based permissions
- Policy objects

### 5. **Monorepo** (Low Priority)
- Yarn workspaces
- Shared packages
- Lerna or Nx

---

## 🎯 Interview Preparation

### Backend Questions:
1. How do you prevent N+1 queries in Rails?
2. Explain difference between `includes`, `preload`, and `eager_load`
3. How do you design RESTful API versioning?
4. How do you prevent SQL injection?
5. Explain thin controller pattern and service objects
6. How do you implement authorization?
7. How do you optimize Elasticsearch queries?

### Frontend Questions:
1. Explain React hooks lifecycle
2. How do you handle async state in React?
3. What is TypeScript and why use it?
4. How do you prevent race conditions in useEffect?
5. Explain server-side vs client-side pagination
6. How do you test React components?
7. What is Module Federation?

### Fullstack Questions:
1. Walk through request flow: Browser → Rails → Database → Browser
2. How do you handle API errors on frontend?
3. Explain CORS and how to configure it
4. How do you optimize full-stack performance?
5. How do you version APIs with breaking changes?

---

## 💼 Resume Highlights

**Backend:**
- REST API development with Ruby on Rails
- Service-oriented architecture (thin controllers, service objects)
- OpenSearch/Elasticsearch integration (search, filters, aggregations)
- Database optimization (N+1 prevention, indexing)
- RSpec testing (unit, integration, services)
- Authorization and security patterns

**Frontend:**
- React + TypeScript production applications
- Type-safe API integration
- Component architecture and state management
- Performance optimization (request deduplication, caching)
- Responsive UI with modern CSS
- Testing with Jest and React Testing Library

**Fullstack:**
- End-to-end feature development (API → UI)
- RESTful API design and documentation
- Database and query optimization
- Security best practices
- Code review and documentation

---

## 🚀 Action Plan

### Week 1-2: Core Skills
- [ ] Practice RSpec testing
- [ ] Learn OpenAPI/Swagger
- [ ] Deep dive into Elasticsearch aggregations
- [ ] Practice Jest + React Testing Library

### Week 3-4: Advanced
- [ ] Authorization patterns (Pundit)
- [ ] API versioning strategies
- [ ] Monorepo setup
- [ ] Cypress E2E testing

### Week 5-6: Interview Prep
- [ ] Review common interview questions
- [ ] Build portfolio project
- [ ] Practice coding challenges
- [ ] Mock interviews

---

## 🧪 RSpec: Mocks vs Stubs - Детальний розбір

### Основні концепції

| Тип | Призначення | Перевірка викликів |
|-----|-------------|-------------------|
| **Stub** | Замінює метод фіксованою відповіддю | ❌ Ні |
| **Mock** | Очікує конкретні виклики методів | ✅ Так |
| **Spy** | Записує виклики для пізнішої перевірки | ✅ Так (після факту) |
| **Double** | Фейковий об'єкт для тестування | ➖ Залежить від методів |

---

### 1. **Stub** - Заглушка (фіксована відповідь)

**Коли використовувати:**
- Потрібно замінити метод простою відповіддю
- НЕ важливо, чи викликали метод
- Потрібно ізолювати тест від зовнішніх залежностей

```ruby
# Stub на реальному об'єкті
describe DocumentSearcher do
  it "searches documents" do
    # Замінюємо метод на фіксовану відповідь
    allow(OPENSEARCH_CLIENT).to receive(:search).and_return({
      'hits' => { 'hits' => [] }
    })
    
    result = DocumentSearcher.new(query: 'test').call
    
    # Перевіряємо тільки результат, НЕ перевіряємо чи викликали search
    expect(result[:documents]).to eq([])
  end
end

# Stub з різними аргументами
describe Calculator do
  it "uses stubbed add method" do
    calculator = Calculator.new
    
    # Stub повертає різні значення залежно від аргументів
    allow(calculator).to receive(:add).with(2, 3).and_return(5)
    allow(calculator).to receive(:add).with(10, 20).and_return(30)
    
    expect(calculator.add(2, 3)).to eq(5)
    expect(calculator.add(10, 20)).to eq(30)
  end
end

# Stub з блоком (динамічна відповідь)
describe UserService do
  it "stubs user creation" do
    allow(User).to receive(:create) do |attributes|
      double('User', id: 123, **attributes)
    end
    
    user = User.create(name: 'John', email: 'john@example.com')
    
    expect(user.id).to eq(123)
    expect(user.name).to eq('John')
  end
end

# Stub ланцюжка методів
describe "Method chaining" do
  it "stubs chained methods" do
    allow(User).to receive_message_chain(:where, :order, :limit).and_return([
      double('User', name: 'Alice'),
      double('User', name: 'Bob')
    ])
    
    users = User.where(active: true).order(:name).limit(2)
    
    expect(users.map(&:name)).to eq(['Alice', 'Bob'])
  end
end
```

---

### 2. **Mock** - Очікування викликів

**Коли використовувати:**
- Важливо перевірити, що метод ВИКЛИКАЛИ
- Потрібно перевірити аргументи виклику
- Потрібно перевірити кількість викликів

```ruby
# Mock - очікуємо виклик методу
describe NotificationService do
  it "sends email notification" do
    mailer = double('Mailer')
    
    # Mock: ОЧІКУЄМО, що deliver_now буде викликано
    expect(mailer).to receive(:deliver_now).once
    
    NotificationService.new(mailer).notify_user('test@example.com')
    
    # Якщо deliver_now НЕ викликали - тест падає
  end
end

# Mock з конкретними аргументами
describe DocumentIndexer do
  it "indexes document with correct data" do
    # Очікуємо виклик з ТОЧНИМИ аргументами
    expect(OPENSEARCH_CLIENT).to receive(:index).with(
      index: 'documents',
      id: '123',
      body: { title: 'Test', content: 'Content' }
    ).and_return({ '_id' => '123' })
    
    DocumentIndexer.index(id: '123', title: 'Test', content: 'Content')
  end
end

# Mock з hash_including (часткове співпадіння)
describe Api::DocumentsController do
  it "logs request params" do
    logger = double('Logger')
    
    # Перевіряємо тільки частину аргументів
    expect(logger).to receive(:info).with(
      hash_including(action: 'create', user_id: 1)
    )
    
    logger.info(action: 'create', user_id: 1, timestamp: Time.now)
  end
end

# Mock з кількістю викликів
describe CacheService do
  it "calls cache clear exactly 3 times" do
    cache = double('Cache')
    
    expect(cache).to receive(:clear).exactly(3).times
    
    3.times { CacheService.clear_cache(cache) }
  end
  
  it "calls cache set at least once" do
    cache = double('Cache')
    
    expect(cache).to receive(:set).at_least(:once)
    
    CacheService.set_multiple(cache, { key1: 'value1', key2: 'value2' })
  end
end

# Mock з порядком викликів
describe PaymentProcessor do
  it "validates before charging" do
    processor = PaymentProcessor.new
    
    expect(processor).to receive(:validate_card).ordered
    expect(processor).to receive(:charge_card).ordered
    expect(processor).to receive(:send_receipt).ordered
    
    processor.process_payment(amount: 100)
  end
end
```

---

### 3. **Spy** - Записує виклики для перевірки ПІСЛЯ

**Коли використовувати:**
- Перевірка викликів ПІСЛЯ виконання коду
- Більш природний стиль тестування (arrange → act → assert)

```ruby
# Spy - перевіряємо ПІСЛЯ виконання
describe Logger do
  it "logs messages" do
    logger = spy('Logger')
    
    # 1. Виконуємо код (logger використовується)
    service = SomeService.new(logger)
    service.perform_action
    
    # 2. ПОТІМ перевіряємо, що було викликано
    expect(logger).to have_received(:info).with('Action started')
    expect(logger).to have_received(:info).with('Action completed')
  end
end

# Spy на реальному об'єкті
describe UserService do
  it "calls external API" do
    # Перетворюємо реальний клас на spy
    allow(ExternalAPI).to receive(:post).and_return({ status: 'ok' })
    
    UserService.sync_user(user_id: 123)
    
    # Перевіряємо ЩО було викликано
    expect(ExternalAPI).to have_received(:post).with(
      '/users/123',
      hash_including(name: 'John')
    )
  end
end

# Spy з instance_spy (для інстансів класу)
describe DocumentProcessor do
  it "processes document" do
    document = instance_spy(Document, title: 'Test')
    
    DocumentProcessor.process(document)
    
    expect(document).to have_received(:save!)
    expect(document).to have_received(:index_in_search)
  end
end
```

---

### 4. **Double** - Фейковий об'єкт

**Коли використовувати:**
- Потрібен простий fake object
- Не хочемо використовувати реальні класи
- Швидші тести (без завантаження моделей)

```ruby
# Простий double
describe DocumentService do
  it "processes document" do
    # Створюємо фейковий документ
    document = double('Document', id: 1, title: 'Test', status: 'draft')
    
    result = DocumentService.process(document)
    
    expect(result[:id]).to eq(1)
  end
end

# Double з методами
describe UserPresenter do
  it "presents user data" do
    user = double('User', {
      name: 'John Doe',
      email: 'john@example.com',
      admin?: false,
      created_at: Time.new(2024, 1, 1)
    })
    
    presenter = UserPresenter.new(user)
    
    expect(presenter.display_name).to eq('John Doe')
    expect(presenter.role).to eq('User')
  end
end

# instance_double - більш строгий (перевіряє існування методів)
describe DocumentSearcher do
  it "searches documents" do
    # instance_double перевіряє, що методи існують в класі Document
    document = instance_double(Document, {
      id: '123',
      title: 'Test',
      to_json: '{"id":"123"}'
    })
    
    # Якщо Document не має методу to_json - RSpec видасть помилку
  end
end

# class_double - для методів класу
describe UserFactory do
  it "creates users" do
    user_class = class_double(User)
    
    allow(user_class).to receive(:create).and_return(
      instance_double(User, id: 1, name: 'John')
    )
    
    user = user_class.create(name: 'John')
    
    expect(user.id).to eq(1)
  end
end
```

---

### 5. **Реальні приклади з Rails**

#### Приклад 1: API Controller з зовнішнім сервісом

```ruby
# app/controllers/api/documents_controller.rb
class Api::DocumentsController < ApplicationController
  def create
    result = DocumentCreator.new(
      params: document_params,
      indexer: OpensearchIndexer.new
    ).call
    
    if result[:success]
      render json: result[:document], status: :created
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end
end

# spec/controllers/api/documents_controller_spec.rb
RSpec.describe Api::DocumentsController, type: :controller do
  describe "POST #create" do
    let(:document_params) { { title: 'Test', content: 'Content' } }
    
    context "when creation succeeds" do
      it "returns created document" do
        # Stub: замінюємо OpensearchIndexer
        fake_indexer = double('OpensearchIndexer')
        allow(OpensearchIndexer).to receive(:new).and_return(fake_indexer)
        allow(fake_indexer).to receive(:index).and_return(true)
        
        # Mock: очікуємо, що DocumentCreator буде викликано
        expect(DocumentCreator).to receive(:new).with(
          params: document_params,
          indexer: fake_indexer
        ).and_call_original
        
        post :create, params: { document: document_params }
        
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['title']).to eq('Test')
      end
    end
    
    context "when creation fails" do
      it "returns error" do
        # Stub з помилкою
        creator = instance_double(DocumentCreator)
        allow(DocumentCreator).to receive(:new).and_return(creator)
        allow(creator).to receive(:call).and_return({
          success: false,
          error: 'Title is required'
        })
        
        post :create, params: { document: {} }
        
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
```

#### Приклад 2: Service Object з OpenSearch

```ruby
# app/services/document_searcher.rb
class DocumentSearcher
  def initialize(query:, client: OPENSEARCH_CLIENT)
    @query = query
    @client = client
  end
  
  def call
    response = @client.search(
      index: 'documents',
      body: build_query
    )
    
    parse_results(response)
  rescue StandardError => e
    Rails.logger.error("Search failed: #{e.message}")
    { documents: [], error: e.message }
  end
  
  private
  
  def build_query
    {
      query: {
        multi_match: {
          query: @query,
          fields: ['title', 'content']
        }
      }
    }
  end
  
  def parse_results(response)
    documents = response['hits']['hits'].map { |hit| hit['_source'] }
    { documents: documents, total: response['hits']['total']['value'] }
  end
end

# spec/services/document_searcher_spec.rb
RSpec.describe DocumentSearcher do
  describe "#call" do
    let(:query) { 'test query' }
    
    context "when search succeeds" do
      it "returns documents" do
        # Stub OpenSearch client
        client = double('OpensearchClient')
        allow(client).to receive(:search).with(
          index: 'documents',
          body: {
            query: {
              multi_match: {
                query: 'test query',
                fields: ['title', 'content']
              }
            }
          }
        ).and_return({
          'hits' => {
            'total' => { 'value' => 2 },
            'hits' => [
              { '_source' => { 'title' => 'Doc 1' } },
              { '_source' => { 'title' => 'Doc 2' } }
            ]
          }
        })
        
        searcher = DocumentSearcher.new(query: query, client: client)
        result = searcher.call
        
        expect(result[:documents]).to have(2).items
        expect(result[:total]).to eq(2)
        expect(result[:documents].first['title']).to eq('Doc 1')
      end
    end
    
    context "when search fails" do
      it "handles error gracefully" do
        # Stub з винятком
        client = double('OpensearchClient')
        allow(client).to receive(:search).and_raise(
          StandardError.new('Connection timeout')
        )
        
        # Mock logger
        allow(Rails.logger).to receive(:error)
        expect(Rails.logger).to receive(:error).with(
          'Search failed: Connection timeout'
        )
        
        searcher = DocumentSearcher.new(query: query, client: client)
        result = searcher.call
        
        expect(result[:documents]).to eq([])
        expect(result[:error]).to eq('Connection timeout')
      end
    end
    
    context "integration with real client" do
      it "sends correct query structure" do
        # Spy на реальному клієнті
        client = spy('OpensearchClient')
        allow(client).to receive(:search).and_return({
          'hits' => { 'total' => { 'value' => 0 }, 'hits' => [] }
        })
        
        DocumentSearcher.new(query: 'test', client: client).call
        
        # Перевіряємо ПІСЛЯ виконання
        expect(client).to have_received(:search).with(
          hash_including(
            index: 'documents',
            body: hash_including(query: anything)
          )
        )
      end
    end
  end
end
```

#### Приклад 3: Background Job з Email

```ruby
# app/jobs/document_notification_job.rb
class DocumentNotificationJob < ApplicationJob
  queue_as :default
  
  def perform(document_id, user_id)
    document = Document.find(document_id)
    user = User.find(user_id)
    
    DocumentMailer.notification(document, user).deliver_now
    
    NotificationLog.create!(
      document: document,
      user: user,
      sent_at: Time.current
    )
  end
end

# spec/jobs/document_notification_job_spec.rb
RSpec.describe DocumentNotificationJob, type: :job do
  describe "#perform" do
    let(:document) { instance_double(Document, id: 1, title: 'Test') }
    let(:user) { instance_double(User, id: 2, email: 'test@example.com') }
    let(:mailer) { instance_double(ActionMailer::MessageDelivery) }
    
    before do
      allow(Document).to receive(:find).with(1).and_return(document)
      allow(User).to receive(:find).with(2).and_return(user)
      allow(DocumentMailer).to receive(:notification).and_return(mailer)
      allow(mailer).to receive(:deliver_now)
      allow(NotificationLog).to receive(:create!)
    end
    
    it "sends email notification" do
      # Mock: перевіряємо що email відправляється
      expect(DocumentMailer).to receive(:notification).with(document, user)
      expect(mailer).to receive(:deliver_now)
      
      DocumentNotificationJob.new.perform(1, 2)
    end
    
    it "creates notification log" do
      # Mock: перевіряємо що лог створюється
      expect(NotificationLog).to receive(:create!).with(
        hash_including(
          document: document,
          user: user
        )
      )
      
      DocumentNotificationJob.new.perform(1, 2)
    end
    
    context "when document not found" do
      it "raises error" do
        allow(Document).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
        
        expect {
          DocumentNotificationJob.new.perform(999, 2)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
```

---

### 6. **Best Practices** 🎯

#### ✅ DO:

```ruby
# 1. Використовуйте stub для замін без перевірки викликів
allow(service).to receive(:call).and_return(result)

# 2. Використовуйте mock коли важливо перевірити виклик
expect(mailer).to receive(:deliver_now)

# 3. Використовуйте spy для природного порядку (act → assert)
logger = spy('Logger')
service.call(logger)
expect(logger).to have_received(:info)

# 4. Stub зовнішні залежності (API, DB, file system)
allow(HTTParty).to receive(:get).and_return({ status: 'ok' })

# 5. Використовуйте instance_double для типової безпеки
user = instance_double(User, name: 'John')  # перевіряє методи User
```

#### ❌ DON'T:

```ruby
# 1. Не використовуйте mock коли не перевіряєте виклики
expect(service).to receive(:call).and_return(result)  # але не викликаєте

# 2. Не робіть stub ВСЬОГО (тести стають марними)
allow(service).to receive(:method1).and_return(1)
allow(service).to receive(:method2).and_return(2)
allow(service).to receive(:method3).and_return(3)
# ... краще використати реальний об'єкт

# 3. Не stub методи що тестуєте
describe Calculator do
  it "adds numbers" do
    calc = Calculator.new
    allow(calc).to receive(:add).and_return(5)  # ❌ Тестуємо stub, не код!
    expect(calc.add(2, 3)).to eq(5)
  end
end

# 4. Не робіть over-mocking (занадто багато моків)
# Якщо >50% тесту - це setup моків, щось не так
```

---

### 7. **Коли використовувати що?**

| Ситуація | Використати | Приклад |
|----------|-------------|---------|
| Замінити відповідь методу | **Stub** | `allow(API).to receive(:get).and_return(data)` |
| Перевірити що метод викликали | **Mock** | `expect(mailer).to receive(:deliver)` |
| Перевірити виклики після коду | **Spy** | `expect(logger).to have_received(:info)` |
| Створити fake object | **Double** | `user = double('User', name: 'John')` |
| Зовнішнє API (HTTP) | **Stub** | `allow(HTTParty).to receive(:post)` |
| База даних (читання) | **Stub** (або фікстури) | `allow(User).to receive(:find)` |
| Email відправка | **Mock** | `expect(mailer).to receive(:deliver_now)` |
| Background jobs | **Mock** або Spy | `expect(SomeJob).to receive(:perform_later)` |
| File system | **Stub** | `allow(File).to receive(:read)` |

---

### 8. **Швидкий довідник**

```ruby
# STUB (замінити відповідь)
allow(obj).to receive(:method).and_return(value)
allow(obj).to receive(:method).with(args).and_return(value)
allow(obj).to receive(:method) { block }

# MOCK (очікувати виклик)
expect(obj).to receive(:method)
expect(obj).to receive(:method).with(args)
expect(obj).to receive(:method).once
expect(obj).to receive(:method).exactly(3).times
expect(obj).to receive(:method).at_least(:once)

# SPY (перевірити після)
obj = spy('Name')
expect(obj).to have_received(:method)
expect(obj).to have_received(:method).with(args)

# DOUBLE (фейковий об'єкт)
obj = double('Name', method1: value1, method2: value2)
obj = instance_double(ClassName, method: value)
obj = class_double(ClassName)

# MATCHER (для аргументів)
expect(obj).to receive(:method).with(
  anything,                    # будь-що
  kind_of(String),            # тип
  hash_including(key: value), # hash з key
  array_including(1, 2),      # array з 1 і 2
  /regex/                     # regex match
)
```

---

## 📚 Resources

### Backend:
- [Rails API Guides](https://guides.rubyonrails.org/api_app.html)
- [Elasticsearch Ruby](https://www.elastic.co/guide/en/elasticsearch/client/ruby-api/current/index.html)
- [RSpec Best Practices](https://rspec.info/)
- [Pundit Authorization](https://github.com/varvet/pundit)

### Frontend:
- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)
- [React Testing Library](https://testing-library.com/react)
- [Jest Documentation](https://jestjs.io/)
- [Cypress Documentation](https://docs.cypress.io/)

### Fullstack:
- [OpenAPI Specification](https://swagger.io/specification/)
- [Webpack Module Federation](https://webpack.js.org/concepts/module-federation/)
- [Micro Frontends](https://micro-frontends.org/)

---

## ✅ Conclusion

**You have 70% of required skills!**

**Strong areas:**
- Rails REST API development
- React + TypeScript
- OpenSearch integration
- Service objects pattern
- Testing basics

**To improve:**
- OpenAPI documentation
- Jest/Cypress testing
- Authorization patterns
- Monorepo experience
- Module Federation

**Focus on:** Testing (Jest + Cypress) and API documentation (OpenAPI) to reach 90%+ match! 🎯
