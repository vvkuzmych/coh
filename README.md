# Career Opportunities Hub (COH)

## Welcome to the Career Opportunities Hub (COH) 👋

**Career Opportunities Hub (COH)** is a recruitment management application designed to streamline the hiring process and provide a comprehensive platform for managing career opportunities within your organization.

This application enables recruiters and hiring managers to efficiently manage candidates, track applications, organize documents, and facilitate a transparent hiring workflow. COH is built for teams of all sizes and focuses on clarity, collaboration, and data-driven decision-making.

## 🎯 Purpose

COH is designed to:
* **Manage recruitment workflows** - Track candidates through the entire hiring pipeline
* **Organize candidate documents** - Store and manage resumes, portfolios, and other materials by status (uploaded, reviewed, signed, archived)
* **Support multi-user collaboration** - Enable teams to work together with role-based access (guest, member, admin, super admin)
* **Provide account-based organization** - Group users and documents under organizational accounts
* **Deliver transparent reporting** - Track metrics like document counts, storage usage, and user activity

## 🏗️ Technical Architecture

This is a **modular monolith Rails application** structured with engines, demonstrating real-world enterprise architecture patterns.

## 📂 Repository Structure

```
coh/
├── mpa/              # Main Application (MPA)
│   ├── app/          # Core application code
│   ├── config/       # Configuration files
│   ├── db/           # Database schema and migrations
│   └── ...           # Standard Rails structure
│
├── packages/         # Modular engines (domain-specific modules)
│   ├── user_management/  # User management engine
│   └── ...              # More engines as needed
│
└── docs/             # Documentation and guides
```

### 🔑 Understanding MPA (Main Application)

**MPA** stands for **Main Application** — the core Rails application that:
- Serves as the primary entry point for the system
- Orchestrates and coordinates between different modules (engines)
- Contains shared infrastructure (database, authentication, core models)
- Mounts and integrates modular engines from `packages/`

This architecture demonstrates a **modular monolith pattern**, which provides:
- Clear separation of concerns (each engine owns its domain)
- Single deployment unit (easier to manage than microservices)
- Shared resources (database, configuration)
- Flexibility to extract modules into separate services if needed

**Why "MPA" and not just "app"?** In enterprise systems, distinguishing the main application from its modules helps teams understand:
- Where core logic lives vs. domain-specific features
- Which code affects the entire system vs. isolated modules
- How to organize work across teams

## 🚀 Getting Started

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd coh

# Navigate to the main application
cd mpa

# Install dependencies
bundle install

# Setup database
rails db:setup

# Start the server
rails server
# or use the custom script that includes asset building
./start-server.sh
```

Visit: http://localhost:3000

### 2. Environment Configuration

Some engines require environment variables:

```bash
cd packages/user_management
cp .env.example .env
# Edit .env with your configuration
bundle install
```

**⚠️ Important:** Never commit `.env` files! They contain sensitive configuration.

### 3. Understanding the Codebase

**Main Application (`/mpa`):**
- Core Rails application
- Database models and migrations
- Shared infrastructure
- Authentication and authorization

**Engines (`/packages/`):**
- Domain-specific modules
- Encapsulated features
- Can be developed independently
- Mounted into the main application

Each module contains its own documentation with detailed setup instructions.

## ✨ Key Features

COH provides comprehensive recruitment management capabilities:

* **User Management** - Role-based access control (guest, member, admin, super admin)
* **Account Organization** - Group users and resources under organizational accounts
* **Document Management** - Track candidate documents through multiple statuses:
  - **Uploaded** - Initial document submission
  - **Reviewed** - Documents under review
  - **Signed** - Approved/finalized documents
  - **Archived** - Historical/completed documents
* **GraphQL API** - Modern API architecture for efficient data querying
* **Modular Architecture** - Clean separation of concerns using Rails Engines
* **Storage Tracking** - Monitor document storage usage per account
* **Audit Trail** - Track creation and update timestamps for all records

## 💻 For Engineers: System Requirements

- **Ruby:** 3.3.6 (stable)
- **Node.js:** 20.18.1 LTS
- **Database:** PostgreSQL (or as configured)
- **Bundler:** 4.x
- **Package Manager:** Yarn

See [Getting Started](#-getting-started) for setup instructions.

## 📚 Technical Documentation

### Architecture & Setup
- **[MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)** - Complete guide for the modular monolith structure
- **[ENV_CONFIGURATION.md](ENV_CONFIGURATION.md)** - Environment variables setup
- **[CI_CD_SETUP.md](CI_CD_SETUP.md)** - CI/CD configuration
- **[packages/user_management/ENV_SETUP.md](packages/user_management/ENV_SETUP.md)** - Engine environment setup

### Technical Decisions & Upgrades
- **[RUBY_DOWNGRADE.md](RUBY_DOWNGRADE.md)** - Why we use Ruby 3.3.6 (stable) instead of 4.0.0
- **[NODE_UPGRADE.md](NODE_UPGRADE.md)** - Node.js 20.18.1 LTS upgrade details
- **[SECURITY_IMPROVEMENTS.md](SECURITY_IMPROVEMENTS.md)** - Security best practices

### Application-Specific
- **[mpa/DATABASE_SCHEMA.md](mpa/DATABASE_SCHEMA.md)** - Complete database structure and relationships
- **[mpa/USER_ROLES.md](mpa/USER_ROLES.md)** - User role system documentation

## 🔒 Security & Best Practices

- **Never commit `.env` files** - They contain sensitive configuration
- Use `.env.example` as a template
- Follow the principle of least privilege for user roles
- Keep dependencies up to date (see Dependabot PRs)
- See [SECURITY_IMPROVEMENTS.md](SECURITY_IMPROVEMENTS.md) for details

## 📊 Data Models

**Core Entities:**
- **Accounts** - Organizations with multiple users
- **Users** - Team members with role-based permissions
- **Documents** - Candidate materials tracked by status

**Relationships:**
- Account has many Users
- User belongs to Account
- User has many Documents
- Documents are accessed via GraphQL for cross-module communication

## 🚀 API & Integration

COH uses **GraphQL** for efficient data querying and cross-module communication:
- Query accounts, users, and documents
- Filter documents by status
- Mutations for create, update, and delete operations
- GraphiQL interface available in development mode at `/graphiql`

## 📝 Contributing

For development guidelines and contribution instructions, please refer to the technical documentation in the `/docs` directory.

---

**Built with:** Ruby on Rails, PostgreSQL, Modern JavaScript  
**Architecture:** Modular Monolith with Rails Engines  
**Last Updated:** January 2026
