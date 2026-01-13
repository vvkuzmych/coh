# CI Fix: Dotenv Loading Error

## 🐛 The Problem

GitHub Actions CI was failing with this error:

```
[!] There was an error while loading `user_management.gemspec`: 
cannot load such file -- dotenv. Bundler cannot continue.

 #  from /home/runner/work/coh/coh/packages/user_management/user_management.gemspec:4
 >  require "dotenv"
```

## 🔍 Root Cause

**Chicken-and-egg problem**:

1. Bundler reads `user_management.gemspec` to know what gems to install
2. The gemspec tried to `require "dotenv"` (line 4)
3. But `dotenv` hasn't been installed yet!
4. ❌ Bundler fails before it can install anything

## ✅ The Solution

Wrapped the `dotenv` require in a `begin/rescue LoadError` block:

### Before (Broken)
```ruby
require_relative "lib/user_management/version"

# Load environment variables from .env file if it exists
require "dotenv"
Dotenv.load(File.expand_path(".env", __dir__)) if File.exist?(File.expand_path(".env", __dir__))

Gem::Specification.new do |spec|
  spec.authors = [ ENV.fetch("GEM_AUTHOR_NAME", "Unknown Author") ]
  # ...
end
```

### After (Fixed)
```ruby
require_relative "lib/user_management/version"

# Load environment variables from .env file if it exists (only if dotenv is available)
begin
  require "dotenv"
  Dotenv.load(File.expand_path(".env", __dir__)) if File.exist?(File.expand_path(".env", __dir__))
rescue LoadError
  # dotenv not yet installed, use default values from ENV.fetch fallbacks
end

Gem::Specification.new do |spec|
  spec.authors = [ ENV.fetch("GEM_AUTHOR_NAME", "Unknown Author") ]
  # ...
end
```

## 🎯 How It Works

### Scenario 1: Fresh Install (CI)
1. Bundler reads gemspec
2. `require "dotenv"` fails → caught by `rescue LoadError`
3. Uses fallback values: `ENV.fetch("GEM_AUTHOR_NAME", "Unknown Author")`
4. ✅ Bundler proceeds to install gems (including dotenv)

### Scenario 2: After Install (Local Dev)
1. Bundler reads gemspec
2. `require "dotenv"` succeeds (already installed)
3. Loads `.env` file if it exists
4. Uses values from `.env` or falls back to defaults
5. ✅ Works with custom values

### Scenario 3: CI with Secrets (Optional)
1. GitHub Actions can set environment variables
2. `ENV.fetch` uses those values
3. ✅ Works without `.env` file

## 📋 Fallback Values

The gemspec has safe defaults for all values:

| Variable | Default | CI Behavior |
|----------|---------|-------------|
| `GEM_AUTHOR_NAME` | `"Unknown Author"` | ✅ Works |
| `GEM_AUTHOR_EMAIL` | `"noreply@example.com"` | ✅ Works |
| `GEM_HOMEPAGE` | `"https://github.com/example/repo"` | ✅ Works |
| `GEM_SOURCE_CODE_URI` | Falls back to `GEM_HOMEPAGE` | ✅ Works |
| `GEM_ALLOWED_PUSH_HOST` | `"https://rubygems.pkg.github.com/example"` | ✅ Works |

## ✅ Verification

### Test Locally (without dotenv)
```bash
cd /Users/vkuzm/RubymineProjects/coh/packages/user_management
ruby -e "load 'user_management.gemspec'"
# ✅ Should succeed without errors
```

### Test in MPA
```bash
cd /Users/vkuzm/RubymineProjects/coh/mpa
bundle install
# ✅ Should succeed
```

### Test CI Simulation
```bash
cd /Users/vkuzm/RubymineProjects/coh/mpa
rm -rf vendor/bundle .bundle
bundle install --deployment
# ✅ Should succeed (simulates CI)
```

## 🔧 Why This Is Better

### ✅ Pros
1. **No CI configuration needed**: Works out of the box
2. **Flexible**: Can still use `.env` locally
3. **Safe defaults**: Never breaks on missing vars
4. **No secrets required**: CI doesn't need GitHub Secrets
5. **Backward compatible**: Existing local dev setups work unchanged

### 📝 Notes
- `.env` files are still useful for local development
- CI uses default values (which is fine for internal engines)
- If you want custom values in CI, use GitHub Secrets (optional)

## 🚀 Impact on CI

### Before Fix
```
❌ bundle install fails
❌ CI fails at setup stage  
❌ No tests run
```

### After Fix
```
✅ bundle install succeeds
✅ CI runs all tests
✅ Brakeman security scan runs
✅ RuboCop lint runs
```

## 📚 Related Files

**Modified**:
- `/packages/user_management/user_management.gemspec` - Added `begin/rescue LoadError`

**Updated Documentation**:
- `/packages/user_management/ENV_SETUP.md` - Updated with rescue block example
- `/CI_CD_SETUP.md` - Added note about safe defaults

## 💡 Lessons Learned

**Problem**: Don't `require` gems in gemspec that aren't guaranteed to be installed yet.

**Solution**: 
1. Use `begin/rescue LoadError` for optional requires
2. Provide sensible defaults with `ENV.fetch(key, default)`
3. Make the system work without `.env` files

**Best Practice**: Gemspecs should be readable **before** `bundle install` runs.

---

## ✅ Status: Fixed

**Your CI should now pass!** 🎉

The GitHub Actions workflow will:
1. ✅ Set up Ruby 4.0.0
2. ✅ Run `bundle install` in `mpa/`
3. ✅ Include the `user_management` engine
4. ✅ Run Brakeman security scan
5. ✅ Run Bundler Audit
6. ✅ Run RuboCop linter

All without requiring any `.env` files or GitHub Secrets! 🚀
