# Environment Variables Configuration Guide

This document explains how environment variables are used across the COH modular monolith project.

## 📁 Structure

```
coh/
├── mpa/
│   └── .env*                         # MPA environment variables (Rails app)
│
└── packages/
    └── user_management/
        ├── .env                      # Engine config (NEVER commit!)
        ├── .env.example             # Template (commit this)
        └── ENV_SETUP.md             # Detailed setup guide
```

## 🔒 Security Rules

### ✅ Always Commit
- `.env.example` files (templates with no sensitive data)
- Documentation files (`ENV_SETUP.md`, etc.)

### ❌ Never Commit  
- `.env` files (contain sensitive personal information)
- Any file with real credentials, emails, or API keys

The `.gitignore` is configured to prevent accidental commits:
```gitignore
/mpa/.env*
/packages/*/.env
!/packages/*/.env.example
```

## 📦 Engine Configuration

Each engine in `packages/` may have its own `.env` file for gemspec configuration.

### User Management Engine

Location: `/packages/user_management/`

**Required Setup:**
```bash
cd packages/user_management
cp .env.example .env
# Edit .env with your information
```

**Variables:**
- `GEM_AUTHOR_NAME` - Your full name
- `GEM_AUTHOR_EMAIL` - Your email (can use GitHub noreply email)
- `GEM_HOMEPAGE` - Repository URL
- `GEM_SOURCE_CODE_URI` - Source code URL
- `GEM_ALLOWED_PUSH_HOST` - Gem registry URL

**Documentation:** See [`packages/user_management/ENV_SETUP.md`](packages/user_management/ENV_SETUP.md) for detailed instructions.

## 🚀 Quick Start for New Team Members

### 1. Setup MPA (if .env is needed)
```bash
cd mpa
# Currently no .env required for MPA
# If needed in future, create .env from .env.example
```

### 2. Setup Each Engine
```bash
cd packages/user_management
cp .env.example .env
nano .env  # or use your favorite editor
```

### 3. Install Dependencies
```bash
# In each directory that has a .env file:
bundle install
```

## 🔄 Adding New Engines

When creating a new engine that needs environment variables:

### 1. Create `.env.example`
```bash
cd packages/your_new_engine
cat > .env.example << 'EOF'
# Your New Engine Configuration
VARIABLE_NAME="default or example value"
EOF
```

### 2. Add `dotenv` to Gemfile
```ruby
# packages/your_new_engine/Gemfile
gem "dotenv"
```

### 3. Use in gemspec
```ruby
# packages/your_new_engine/your_new_engine.gemspec
require "dotenv"
Dotenv.load(File.expand_path(".env", __dir__)) if File.exist?(File.expand_path(".env", __dir__))

Gem::Specification.new do |spec|
  spec.name = ENV.fetch("VARIABLE_NAME", "default_value")
end
```

### 4. Create Documentation
Create an `ENV_SETUP.md` file explaining each variable.

### 5. Verify .gitignore
The root `.gitignore` already covers `/packages/*/.env`, but verify it's there.

## 🧪 Testing Environment Variables

### Check if .env is loaded
```bash
cd packages/user_management
bundle exec ruby -e "require 'dotenv'; Dotenv.load('.env'); puts ENV['GEM_AUTHOR_NAME']"
```

### Verify .env is ignored by git
```bash
cd /path/to/coh
git status
# .env files should NOT appear in untracked files
```

### Check what will be committed
```bash
git add -A
git status
# Verify only .env.example appears, not .env
git reset  # undo the add if needed
```

## 📋 Environment Variables by Component

### MPA (Main Application)
Currently uses Rails encrypted credentials. Traditional `.env` can be added if needed.

**Future .env variables might include:**
- `DATABASE_URL`
- `REDIS_URL`
- `SECRET_KEY_BASE`
- API keys for external services

### User Management Engine
**Current variables:**
- `GEM_AUTHOR_NAME` - Gem author name
- `GEM_AUTHOR_EMAIL` - Gem author email
- `GEM_HOMEPAGE` - Project homepage URL
- `GEM_SOURCE_CODE_URI` - Source code URL
- `GEM_ALLOWED_PUSH_HOST` - Gem registry host

## 🎯 Best Practices

### For Development
1. **Never share `.env` files** - Each developer has their own
2. **Use meaningful defaults** - Allow code to work without .env when possible
3. **Document all variables** - Keep `.env.example` and docs up to date
4. **Use `ENV.fetch(key, default)`** - Provide fallback values

### For CI/CD
1. **Use GitHub Secrets** or your CI platform's secret management
2. **Don't rely on `.env` files** in CI (use environment variables directly)
3. **Test with minimal env vars** - Verify defaults work

### For Production
1. **Use proper secret management** (AWS Secrets Manager, HashiCorp Vault, etc.)
2. **Never deploy `.env` files** to production servers
3. **Use environment variables** set by your hosting platform
4. **Rotate credentials regularly**

## 🛠️ Troubleshooting

### "cannot load such file -- dotenv"
```bash
cd packages/user_management
bundle install
```

### Variables not loading
1. Check file exists: `ls -la packages/user_management/.env`
2. Check syntax: No spaces around `=`, no quotes around values unless needed
3. Check file permissions: `chmod 600 .env`

### .env appears in git status
```bash
# Check .gitignore
cat .gitignore | grep "\.env"

# Should see:
# /mpa/.env*
# /packages/*/.env

# If not there, add it and commit .gitignore
```

### Engine can't find variables
The `.env` file should be in the same directory as the gemspec:
```
packages/user_management/
├── .env                    # <- Here
└── user_management.gemspec # <- Next to this
```

## 📚 Related Documentation

- [Main README](/README.md) - Project overview
- [Migration Guide](/MIGRATION_GUIDE.md) - Restructuring details  
- [User Management ENV Setup](/packages/user_management/ENV_SETUP.md) - Detailed engine setup
- [dotenv Documentation](https://github.com/bkeepers/dotenv) - dotenv gem docs

## 💡 Tips

### Getting Your GitHub Noreply Email
1. Go to GitHub → Settings → Emails
2. Check "Keep my email addresses private"
3. Copy the email shown: `12345678+username@users.noreply.github.com`
4. Use this in `GEM_AUTHOR_EMAIL`

### Template for New Engineers
Share this checklist with new team members:
- [ ] Clone repository
- [ ] For each engine with `.env.example`:
  - [ ] `cp .env.example .env`
  - [ ] Edit `.env` with your information
  - [ ] `bundle install`
- [ ] Verify app boots: `cd mpa && rails server`

---

**Remember: Protect sensitive data! Keep `.env` files local and never commit them.** 🔐
