# CI/CD Setup for Modular Monolith

This document explains how CI/CD is configured for the modular monolith structure.

## 🏗️ Structure Impact on CI/CD

After restructuring to a modular monolith:

```
coh/
├── .ruby-version          ← Required at root for GitHub Actions
├── .node-version         ← Required at root for GitHub Actions
├── .github/
│   └── workflows/
│       └── ci.yml        ← Updated to use mpa/ directory
├── mpa/                  ← Rails application
│   ├── .ruby-version    ← Also kept here for local development
│   ├── Gemfile
│   ├── bin/
│   └── ...
└── packages/             ← Engines
```

## 🔧 What Changed

### 1. Version Files at Root

**Why**: GitHub Actions `ruby/setup-ruby@v1` looks for `.ruby-version` at the repository root.

**Solution**: Version files are now at both locations:
- **Root**: `/` - For CI/CD (GitHub Actions)
- **MPA**: `/mpa/` - For local development

Files:
- `.ruby-version` - Ruby 4.0.0
- `.node-version` - Node 12.16.3

### 2. Updated GitHub Actions Workflow

**File**: `.github/workflows/ci.yml`

All steps now use `working-directory: mpa` to run commands in the Rails app directory.

#### Changes Made:

**Before:**
```yaml
- name: Set up Ruby
  uses: ruby/setup-ruby@v1
  with:
    bundler-cache: true

- name: Scan for security vulnerabilities
  run: bin/brakeman --no-pager
```

**After:**
```yaml
- name: Set up Ruby
  uses: ruby/setup-ruby@v1
  with:
    bundler-cache: true
    working-directory: mpa  # ← Added

- name: Scan for security vulnerabilities
  working-directory: mpa    # ← Added
  run: bin/brakeman --no-pager
```

### 3. Updated File Paths in Cache Configuration

**Before:**
```yaml
DEPENDENCIES_HASH: ${{ hashFiles('.ruby-version', '**/.rubocop.yml', 'Gemfile.lock') }}
path: ${{ env.RUBOCOP_CACHE_ROOT }}
```

**After:**
```yaml
DEPENDENCIES_HASH: ${{ hashFiles('.ruby-version', 'mpa/**/.rubocop.yml', 'mpa/Gemfile.lock') }}
path: mpa/${{ env.RUBOCOP_CACHE_ROOT }}
```

## 📋 Current CI Jobs

### Job 1: `scan_ruby`
Runs security scans on the MPA.

```yaml
- Checkout code
- Set up Ruby (from .ruby-version at root)
- Run Brakeman (in mpa/)
- Run Bundler Audit (in mpa/)
```

### Job 2: `lint`
Runs RuboCop linting on the MPA.

```yaml
- Checkout code
- Set up Ruby (from .ruby-version at root)
- Prepare RuboCop cache (mpa/tmp/rubocop)
- Run RuboCop (in mpa/)
```

## 🔮 Adding CI for Engines

When you want to add CI checks for engines:

### Option 1: Add to Existing Jobs

Add steps to lint/test each engine:

```yaml
- name: Lint User Management Engine
  working-directory: packages/user_management
  run: bundle exec rubocop
```

### Option 2: Create Separate Jobs

Create dedicated jobs for each engine:

```yaml
test_user_management:
  runs-on: ubuntu-latest
  steps:
    - name: Checkout code
      uses: actions/checkout@v6
    
    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        bundler-cache: true
        working-directory: packages/user_management
    
    - name: Run tests
      working-directory: packages/user_management
      run: bundle exec rspec
```

### Option 3: Matrix Strategy

Test multiple engines in parallel:

```yaml
test_engines:
  runs-on: ubuntu-latest
  strategy:
    matrix:
      engine: [user_management, api, admin]
  steps:
    - name: Checkout code
      uses: actions/checkout@v6
    
    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        bundler-cache: true
        working-directory: packages/${{ matrix.engine }}
    
    - name: Run tests
      working-directory: packages/${{ matrix.engine }}
      run: bundle exec rspec
```

## 🧪 Testing CI Changes Locally

### Using Act (GitHub Actions Locally)

```bash
# Install act (https://github.com/nektos/act)
brew install act

# Run CI locally
act -j scan_ruby
act -j lint
```

### Manual Testing

```bash
# Simulate what CI does
cd /Users/vkuzm/RubymineProjects/coh

# Check Ruby version
cat .ruby-version

# Go to MPA and run checks
cd mpa
bin/brakeman --no-pager
bin/bundler-audit
bin/rubocop -f github
```

## 🚨 Common CI Issues & Solutions

### Issue 1: "ruby-version needs to be specified"

**Cause**: `.ruby-version` not found at repository root.

**Solution**:
```bash
cd /path/to/coh
cp mpa/.ruby-version .
```

### Issue 2: "cannot find Gemfile"

**Cause**: CI trying to run bundle in root instead of `mpa/`.

**Solution**: Add `working-directory: mpa` to the step:
```yaml
- name: Your step
  working-directory: mpa
  run: your-command
```

### Issue 3: "bin/brakeman: No such file or directory"

**Cause**: Running command in wrong directory.

**Solution**: Ensure `working-directory: mpa` is set:
```yaml
- name: Scan with Brakeman
  working-directory: mpa
  run: bin/brakeman --no-pager
```

### Issue 4: "Your bundle only supports platforms arm64-darwin"

**Cause**: `Gemfile.lock` doesn't include `x86_64-linux` platform.

**Solution**: Already fixed! We added the platform in the migration:
```bash
cd mpa
bundle lock --add-platform x86_64-linux
```

## 📝 Deployment Considerations

### Docker Builds

Update your `Dockerfile` to account for the new structure:

**Before:**
```dockerfile
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY . .
```

**After:**
```dockerfile
COPY mpa/Gemfile mpa/Gemfile.lock ./
RUN bundle install
COPY mpa/ .
```

Or use a context path:

```bash
docker build -f mpa/Dockerfile mpa/
```

### Kamal Deployment

Update `config/deploy.yml`:

```yaml
# If using Kamal, update paths
builder:
  context: ./mpa
  dockerfile: Dockerfile
```

### Heroku

Update `Procfile` or specify the directory:

```yaml
# In mpa/Procfile
web: bundle exec puma -C config/puma.rb
```

### Other Platforms

- **Fly.io**: Update `fly.toml` to point to `mpa/`
- **Render**: Set root directory to `mpa` in dashboard
- **Railway**: Configure root directory in settings

## 🔐 Environment Variables in CI

### MPA Environment Variables

Set in GitHub Actions Secrets if needed:

```yaml
env:
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
  RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
```

### Engine Environment Variables

For engines that need `.env` configuration:

```yaml
- name: Setup engine env
  working-directory: packages/user_management
  run: |
    echo "GEM_AUTHOR_NAME=${{ secrets.GEM_AUTHOR_NAME }}" >> .env
    echo "GEM_AUTHOR_EMAIL=${{ secrets.GEM_AUTHOR_EMAIL }}" >> .env
```

**Note**: Engine `.env` vars are only needed when **building/packaging** the gem, not for runtime.

## 📚 Related Documentation

- [Main README](README.md) - Project overview
- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) - Structure changes
- [ENV_CONFIGURATION.md](ENV_CONFIGURATION.md) - Environment variables
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## ✅ Verification Checklist

Before pushing:

- [ ] `.ruby-version` exists at root
- [ ] `.node-version` exists at root (if using Node)
- [ ] All CI jobs have `working-directory: mpa` where needed
- [ ] File paths in cache configuration updated to `mpa/*`
- [ ] `mpa/Gemfile.lock` includes `x86_64-linux` platform
- [ ] CI passes on your branch

## 💡 Best Practices

1. **Keep version files in sync**: If you update `mpa/.ruby-version`, also update `/.ruby-version`
2. **Test CI changes in branches**: Don't merge breaking CI changes to main
3. **Use act for local testing**: Test GitHub Actions locally before pushing
4. **Monitor CI times**: Modular structure shouldn't significantly impact CI performance
5. **Add engine tests gradually**: Start with MPA, add engine CI as needed

---

**Your CI is now configured for the modular monolith structure!** 🚀
