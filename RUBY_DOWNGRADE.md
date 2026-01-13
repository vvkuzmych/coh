# Ruby Downgrade: 4.0.0 → 3.3.6

## Summary

Downgraded from **Ruby 4.0.0 (preview)** to **Ruby 3.3.6 (stable)** to fix Rails CLI compatibility issues.

## Problem

Ruby 4.0.0 is a **preview/development version** released in December 2024. It has breaking compatibility issues with Rails 8.1:

### Issues with Ruby 4.0.0:
- ❌ `rails server` - showed `rails new` help instead of starting server
- ❌ `rails generate` - showed `rails new` help instead of generating files
- ❌ `rails console` - likely broken
- ❌ Corrupted `bin/rails` binstub
- ❌ General CLI instability

**Root Cause:** The Rails CLI has not been updated to work with Ruby 4.0.0's internal changes.

## Solution

Downgraded to **Ruby 3.3.6** (latest stable release).

### Steps Taken:

1. **Installed Ruby 3.3.6:**
   ```bash
   rbenv install 3.3.6
   ```

2. **Updated `.ruby-version` files:**
   - `/Users/vkuzm/RubymineProjects/coh/.ruby-version`
   - `/Users/vkuzm/RubymineProjects/coh/mpa/.ruby-version`

3. **Reinstalled gems:**
   ```bash
   cd mpa
   gem install bundler
   bundle install
   ```

4. **Fixed `bin/rails` binstub:**
   - Replaced corrupted RubyGems-generated file with proper Rails binstub

## Verification

All Rails commands now work correctly:

### ✅ Working Commands:

```bash
cd mpa

# Generate models, controllers, migrations
bin/rails generate model Account name:string email:string
bin/rails generate controller Welcome index

# Start server
bin/rails server
# or
rails s

# Console
bin/rails console

# Database operations
bin/rails db:migrate
bin/rails db:rollback
```

### Example Output:

```bash
$ bin/rails generate model Account name:string email:string
      invoke  active_record
      create    db/migrate/20260113152543_create_accounts.rb
      create    app/models/account.rb
```

## Files Modified

- `.ruby-version` (root) - `4.0.0` → `3.3.6`
- `mpa/.ruby-version` - `4.0.0` → `3.3.6`
- `mpa/bin/rails` - Fixed corrupted binstub
- `README.md` - Updated quick start instructions
- `mpa/start-server.sh` - Updated to use `bin/rails server`

## Recommendation

**Do not use Ruby 4.0.0 for production Rails applications.**

Ruby 4.0.0 is a preview release intended for:
- Testing new Ruby features
- Compatibility testing for gem authors
- Ruby core development

For production Rails apps, use:
- **Ruby 3.3.x** (latest stable, recommended)
- **Ruby 3.2.x** (stable)
- **Ruby 3.1.x** (minimum for Rails 8)

## CI/CD Impact

Update `.github/workflows/ci.yml` to use Ruby 3.3.6:

```yaml
- uses: ruby/setup-ruby@v1
  with:
    ruby-version: '3.3.6'  # Was: 4.0.0
    bundler-cache: true
```

The CI will now automatically use the correct Ruby version from `.ruby-version` file.

## Related Documentation

- [NODE_UPGRADE.md](NODE_UPGRADE.md) - Node.js upgrade to 20.18.1 LTS
- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) - Modular monolith structure
- [README.md](README.md) - Quick start guide

## Date

January 13, 2026
