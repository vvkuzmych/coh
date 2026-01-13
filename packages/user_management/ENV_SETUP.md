# Environment Variables Setup for User Management Engine

This document explains how to configure environment variables for the User Management engine.

## 🔒 Security Notice

**IMPORTANT**: Never commit `.env` files to git! They contain sensitive information like email addresses and repository URLs.

## 📋 Quick Setup

### 1. Copy the Example File

```bash
cd /Users/vkuzm/RubymineProjects/coh/packages/user_management
cp .env.example .env
```

### 2. Edit Your `.env` File

Open `.env` and fill in your personal information:

```bash
# Gem Author Information
GEM_AUTHOR_NAME="Your Full Name"
GEM_AUTHOR_EMAIL="your.email@example.com"

# Repository Information
GEM_HOMEPAGE="https://github.com/yourusername/yourrepo"
GEM_SOURCE_CODE_URI="https://github.com/yourusername/yourrepo"

# Package Registry (for private gems)
GEM_ALLOWED_PUSH_HOST="https://rubygems.pkg.github.com/yourusername"
```

### 3. Install Dependencies

The engine uses `dotenv` gem to load environment variables:

```bash
bundle install
```

## 🔑 Environment Variables Reference

### `GEM_AUTHOR_NAME`
- **Description**: Your full name as the gem author
- **Required**: Yes
- **Example**: `"Volodymyr Kuzmych"`
- **Default if missing**: `"Unknown Author"`

### `GEM_AUTHOR_EMAIL`
- **Description**: Your email address for gem authorship
- **Required**: Yes
- **Example**: `"your.email@example.com"`
- **Default if missing**: `"noreply@example.com"`
- **Note**: Can be your GitHub noreply email (e.g., `12345678+username@users.noreply.github.com`)

### `GEM_HOMEPAGE`
- **Description**: URL to the project homepage
- **Required**: Yes
- **Example**: `"https://github.com/yourusername/coh"`
- **Default if missing**: `"https://github.com/example/repo"`

### `GEM_SOURCE_CODE_URI`
- **Description**: URL to the source code repository
- **Required**: Yes
- **Example**: `"https://github.com/yourusername/coh"`
- **Default if missing**: Falls back to `GEM_HOMEPAGE`

### `GEM_ALLOWED_PUSH_HOST`
- **Description**: Registry URL where the gem can be pushed (prevents accidental publishing to rubygems.org)
- **Required**: Yes
- **Example**: `"https://rubygems.pkg.github.com/yourusername"`
- **Default if missing**: `"https://rubygems.pkg.github.com/example"`

## 📝 Example Configurations

### For GitHub Users

```bash
GEM_AUTHOR_NAME="John Doe"
GEM_AUTHOR_EMAIL="12345678+johndoe@users.noreply.github.com"
GEM_HOMEPAGE="https://github.com/johndoe/coh"
GEM_SOURCE_CODE_URI="https://github.com/johndoe/coh"
GEM_ALLOWED_PUSH_HOST="https://rubygems.pkg.github.com/johndoe"
```

### For Private/Internal Projects

```bash
GEM_AUTHOR_NAME="Development Team"
GEM_AUTHOR_EMAIL="dev-team@company.com"
GEM_HOMEPAGE="https://git.company.com/projects/coh"
GEM_SOURCE_CODE_URI="https://git.company.com/projects/coh"
GEM_ALLOWED_PUSH_HOST="https://gems.company.com"
```

## 🔍 How It Works

### In `user_management.gemspec`

The gemspec file loads environment variables using `dotenv`:

```ruby
begin
  require "dotenv"
  Dotenv.load(File.expand_path(".env", __dir__)) if File.exist?(File.expand_path(".env", __dir__))
rescue LoadError
  # dotenv not yet installed, use default values from ENV.fetch fallbacks
end

Gem::Specification.new do |spec|
  spec.authors = [ ENV.fetch("GEM_AUTHOR_NAME", "Unknown Author") ]
  spec.email   = [ ENV.fetch("GEM_AUTHOR_EMAIL", "noreply@example.com") ]
  # ... more configuration
end
```

**Note**: The `begin/rescue LoadError` ensures the gemspec can be read even before `dotenv` is installed (important for CI/CD).

### Fallback Values

If a `.env` file doesn't exist or a variable is missing, the gemspec uses safe default values:
- This prevents build failures
- Allows the engine to work out-of-the-box for testing
- You should still configure your own values for production use

## 🛡️ Security Best Practices

### ✅ DO

- ✅ Copy `.env.example` to `.env` and customize it
- ✅ Keep `.env` files local to your machine
- ✅ Use GitHub's noreply email for public repositories
- ✅ Document any new environment variables in `.env.example`
- ✅ Review `.gitignore` to ensure `.env` is listed

### ❌ DON'T

- ❌ **NEVER** commit `.env` files to git
- ❌ **NEVER** share `.env` files in chat/email
- ❌ **NEVER** include sensitive credentials in `.env.example`
- ❌ Don't use production credentials in development `.env`
- ❌ Don't hardcode values in the gemspec

## 🧪 Testing Your Configuration

### Verify Environment Variables Load

```bash
cd /Users/vkuzm/RubymineProjects/coh/packages/user_management

# Check if .env exists
ls -la .env

# Test that variables are loaded
bundle exec ruby -e "require 'dotenv'; Dotenv.load('.env'); puts ENV['GEM_AUTHOR_NAME']"
```

### Check Gemspec Configuration

```bash
gem specification user_management.gemspec
```

You should see your configured values in the output.

## 🚨 Troubleshooting

### Problem: "cannot load such file -- dotenv"

**Solution**: Run `bundle install` in the engine directory:
```bash
cd /Users/vkuzm/RubymineProjects/coh/packages/user_management
bundle install
```

### Problem: Still seeing default values

**Solution**: 
1. Verify `.env` file exists in the engine directory
2. Check file permissions: `ls -la .env`
3. Ensure variable names match exactly (case-sensitive)
4. Check for syntax errors in `.env` (no spaces around `=`)

### Problem: Variables not loading in MPA

**Solution**: Environment variables are only needed when building/packaging the engine gem. The MPA doesn't need these variables at runtime.

## 📁 File Locations

```
packages/user_management/
├── .env                    # Your personal config (NEVER commit!)
├── .env.example           # Template (commit this)
├── ENV_SETUP.md           # This file
├── Gemfile                # Includes dotenv gem
└── user_management.gemspec # Uses ENV variables
```

## 🔄 Team Collaboration

### For Team Members

Each team member should:
1. Clone the repository
2. Copy `.env.example` to `.env`
3. Fill in their own information
4. Never commit their `.env` file

### For New Engines

When creating new engines, follow this pattern:
1. Create `.env.example` with variable templates
2. Add `.env` to `.gitignore` (already done at root level)
3. Add `dotenv` to the engine's `Gemfile`
4. Use `ENV.fetch()` in the gemspec
5. Create an `ENV_SETUP.md` documentation file

## 📚 Related Documentation

- [Main Project README](/README.md)
- [Migration Guide](/MIGRATION_GUIDE.md)
- [dotenv Gem Documentation](https://github.com/bkeepers/dotenv)

## 💡 Pro Tips

1. **Use GitHub Noreply Email**: Get it from GitHub Settings → Emails → "Keep my email addresses private"
2. **Validate on CI/CD**: Ensure CI has environment variables configured (if needed)
3. **Update Example File**: When adding new variables, update `.env.example` immediately
4. **Document Defaults**: Always provide sensible defaults in gemspec using `ENV.fetch(key, default)`

---

**Remember**: Security starts with keeping sensitive data out of version control! 🔐
