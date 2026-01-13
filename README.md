# Career Opportunities Hub (COH)

## Welcome to the Career Opportunities Hub (COH) 👋

This repository serves as a central hub for exploring career opportunities at our company. It contains example projects, exercises, and supporting materials designed to give candidates a realistic view of how we work.

COH is intended for engineers and non-engineers alike and focuses on clarity, collaboration, and practical problem-solving.

## 🎯 Purpose

The goals of this repository are to:
* Provide a single entry point for career-related exercises and materials
* Share realistic, representative projects
* Create a fair and transparent candidate experience
* Support multiple roles and disciplines

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

Each project or exercise contains its own README with detailed instructions.

## 🧭 What We Value

We're interested in:
* **Clear thinking and communication** - Can you explain your decisions?
* **Practical problem-solving** - Real-world solutions over theoretical perfection
* **Thoughtful trade-offs** - Understanding when to optimize vs. when "good enough" is best
* **Maintainable and readable work** - Code that others can understand and extend

**Remember:** There is often more than one correct solution. We value your reasoning as much as the result.

## 🤝 Inclusivity

COH is designed to be:
* **Role-agnostic where possible** - Exercises suitable for various backgrounds
* **Accessible to people with different experience levels** - Clear instructions and context
* **Focused on skills, not trick questions** - Real problems, not puzzles
* **Open to thoughtful assumptions** - If something is unclear, document your reasoning

If you have questions or need clarification, please reach out to your point of contact.

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

## 📬 Questions & Support

If you have questions or need clarification:
1. Check the relevant documentation in this repository
2. Review the specific exercise or project README
3. Contact your point of contact with specific questions

We encourage thoughtful questions and welcome discussions about trade-offs and design decisions.

## 📝 License & Usage

This repository is intended solely for career exploration and evaluation purposes. Please do not reuse or redistribute its contents unless explicitly permitted.

---

**Built with:** Ruby on Rails, PostgreSQL, Modern JavaScript  
**Architecture:** Modular Monolith with Rails Engines  
**Last Updated:** January 2026
