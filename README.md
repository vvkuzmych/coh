# COH - Modular Monolith

This is a modular monolith Rails application structured with engines.

## Structure

```
coh/
├── mpa/              # Main Rails application (MPA = Main Application)
│   ├── app/
│   ├── config/
│   ├── Gemfile
│   └── ...           # Standard Rails structure
│
└── packages/         # Modular engines
    ├── user_management/  # User management engine
    └── ...              # More engines as needed
```

## 🚀 Quick Start

### 1. MPA (Main Application)

```bash
cd mpa
bundle install
rails db:setup
rails server
```

### 2. Setup Engine Environment Variables

Each engine may need environment configuration:

```bash
cd packages/user_management
cp .env.example .env
# Edit .env with your personal information
bundle install
```

**⚠️ Never commit `.env` files!**

### Working with Engines

Engines in `packages/` are Rails Engines that encapsulate specific domain logic. Each engine:
- Has its own Gemfile
- Has its own routes
- Can be mounted in the main app
- Maintains separation of concerns
- May have its own `.env` configuration

## Development

- **Main app**: `/mpa`
- **Engines**: `/packages/*`

## Architecture

This project uses a modular monolith pattern:
- Logical separation through engines
- Single deployment unit
- Shared database (or separate as needed)
- Clear boundaries between modules

## 📚 Documentation

- **[MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)** - Complete guide for the modular monolith structure
- **[ENV_CONFIGURATION.md](ENV_CONFIGURATION.md)** - Environment variables setup across all components
- **[CI_CD_SETUP.md](CI_CD_SETUP.md)** - CI/CD configuration for modular monolith
- **[CI_FIX_DOTENV.md](CI_FIX_DOTENV.md)** - Fix for dotenv loading error in CI
- **[SECURITY_IMPROVEMENTS.md](SECURITY_IMPROVEMENTS.md)** - Security improvements and env vars
- **[NODE_UPGRADE.md](NODE_UPGRADE.md)** - Node.js upgrade from 12.16.3 to 20.18.1 LTS
- **[packages/user_management/ENV_SETUP.md](packages/user_management/ENV_SETUP.md)** - User Management engine environment setup

## 🔒 Security

- **Never commit `.env` files** - They contain sensitive personal information
- Use `.env.example` as a template
- Each developer maintains their own `.env` files locally
- See [ENV_CONFIGURATION.md](ENV_CONFIGURATION.md) for details
