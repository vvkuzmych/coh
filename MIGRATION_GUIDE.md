# COH Modular Monolith Migration Guide

This document explains the new structure and how to work with it.

## ✅ What Changed

### Before
```
/Users/vkuzm/RubymineProjects/coh/
├── .git/
├── app/
├── config/
├── Gemfile
└── ... (standard Rails structure)
```

### After
```
/Users/vkuzm/RubymineProjects/coh/
├── .git/                           # Git repo stays at root
├── .gitignore                     # Updated for new structure
├── README.md                       # Root README
├── MIGRATION_GUIDE.md             # This file
│
├── mpa/                           # Main Rails Application
│   ├── app/
│   ├── config/
│   ├── Gemfile                    # Main app dependencies
│   ├── Gemfile.lock              # Now includes x86_64-linux platform
│   └── ... (all Rails files)
│
└── packages/                      # Modular Engines
    └── user_management/           # User Management Engine
        ├── app/
        ├── config/
        ├── lib/
        ├── Gemfile                # Engine dependencies
        └── user_management.gemspec
```

## 🚀 Getting Started

### 1. Working with MPA (Main Application)

```bash
cd /Users/vkuzm/RubymineProjects/coh/mpa

# Install dependencies
bundle install

# Database setup (if needed)
rails db:create db:migrate

# Run the server
rails server
# or
bin/dev  # if using Procfile.dev
```

### 2. Setting Up Environment Variables

Each engine may require environment variables for configuration.

#### User Management Engine

```bash
cd /Users/vkuzm/RubymineProjects/coh/packages/user_management

# Copy the example .env file
cp .env.example .env

# Edit .env with your personal information
nano .env  # or use your preferred editor

# Install dependencies (includes dotenv gem)
bundle install
```

**⚠️ IMPORTANT**: Never commit `.env` files! They contain sensitive information.

See detailed documentation:
- [ENV_CONFIGURATION.md](/ENV_CONFIGURATION.md) - Overview of all environment variables
- [packages/user_management/ENV_SETUP.md](/packages/user_management/ENV_SETUP.md) - Detailed engine setup

### 3. Working with Engines

#### User Management Engine

```bash
cd /Users/vkuzm/RubymineProjects/coh/packages/user_management

# The engine is automatically loaded when MPA boots
```

The engine is mounted at: **`/user_management`**

## 📁 How to Add New Engines

### Method 1: Using Rails Generator (Recommended)

```bash
cd /Users/vkuzm/RubymineProjects/coh/packages
../mpa/bin/rails plugin new <engine_name> --mountable --skip-test

# Example: Create an API engine
../mpa/bin/rails plugin new api --mountable --skip-test

# Clean up the nested git
cd <engine_name>
rm -rf .git .github
```

### Method 2: Manual Creation

1. Create the engine directory structure
2. Add the engine to `mpa/Gemfile`:
   ```ruby
   gem "engine_name", path: "../packages/engine_name"
   ```
3. Mount it in `mpa/config/routes.rb`:
   ```ruby
   mount EngineName::Engine, at: "/engine_name"
   ```
4. Run `bundle install` in MPA

## 🏗️ Engine Structure

Each engine follows this structure:

```
packages/<engine_name>/
├── app/
│   ├── controllers/<engine_name>/
│   ├── models/<engine_name>/
│   ├── views/
│   └── ...
├── config/
│   └── routes.rb              # Engine routes
├── lib/
│   ├── <engine_name>/
│   │   ├── engine.rb         # Engine configuration
│   │   └── version.rb
│   └── <engine_name>.rb
├── Gemfile                    # Engine-specific dependencies
└── <engine_name>.gemspec      # Gem specification
```

## 🔌 Connecting Engines to MPA

### 1. Add to MPA's Gemfile

```ruby
# In /Users/vkuzm/RubymineProjects/coh/mpa/Gemfile
gem "user_management", path: "../packages/user_management"
```

### 2. Mount in Routes

```ruby
# In /Users/vkuzm/RubymineProjects/coh/mpa/config/routes.rb
Rails.application.routes.draw do
  mount UserManagement::Engine, at: "/user_management"
end
```

### 3. Install

```bash
cd /Users/vkuzm/RubymineProjects/coh/mpa
bundle install
```

## 🧪 Testing

### Test MPA
```bash
cd /Users/vkuzm/RubymineProjects/coh/mpa
bundle exec rspec  # or your test framework
```

### Test Engine
```bash
cd /Users/vkuzm/RubymineProjects/coh/packages/user_management
bundle exec rspec
```

## 📦 CI/CD Changes

### Gemfile.lock Platforms

The `mpa/Gemfile.lock` now includes both platforms:
- `arm64-darwin-24` (macOS Apple Silicon)
- `x86_64-linux` (Linux CI/CD)

This fixes the CI error: `Your bundle only supports platforms ["arm64-darwin-24"]`

### GitHub Actions

Update your CI workflow to use the MPA directory:

```yaml
- name: Bundle install
  working-directory: mpa
  run: bundle install

- name: Run tests
  working-directory: mpa
  run: bundle exec rspec
```

## 🎯 Benefits

1. **Separation of Concerns**: Each engine handles a specific domain
2. **Independent Development**: Engines can be developed/tested independently
3. **Reusability**: Engines can be extracted to separate gems if needed
4. **Clear Boundaries**: Prevents tight coupling between modules
5. **Team Scalability**: Different teams can own different engines

## 📝 Notes

- Git repository stays at root level
- All engines share the same database by default (but can be configured separately)
- Engines are isolated namespaces (e.g., `UserManagement::User`)
- Assets and views are also namespaced

## 🔍 Verification

Check that everything is working:

```bash
cd /Users/vkuzm/RubymineProjects/coh/mpa

# Check routes
bin/rails routes | grep user_management

# Check engine is loaded
bin/rails runner "puts UserManagement::Engine.name"

# Boot the app
bin/rails server
```

## 🆘 Troubleshooting

### Issue: "cannot load such file -- user_management"
**Solution**: Run `bundle install` in the MPA directory

### Issue: Routes not showing
**Solution**: Verify the engine is mounted in `config/routes.rb`

### Issue: CI fails with platform error
**Solution**: Run `bundle lock --add-platform x86_64-linux` in MPA directory

## 📚 Further Reading

- [Rails Engines Guide](https://guides.rubyonrails.org/engines.html)
- [Modular Monolith Architecture](https://martinfowler.com/bliki/MonolithFirst.html)
- [Component-Based Rails Applications](https://cbra.info/)
