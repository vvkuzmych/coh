# UserManagement Engine

This Rails Engine handles all user-related functionality including:
- User profiles
- User data management
- User-related business logic

## Structure

This is a mountable Rails Engine with isolated namespace (`UserManagement`).

```
user_management/
├── app/
│   ├── controllers/user_management/  # Controllers namespaced
│   ├── models/user_management/       # Models namespaced
│   ├── views/                        # Views
│   └── ...
├── config/
│   └── routes.rb                     # Engine routes
├── lib/
│   └── user_management/
│       └── engine.rb                 # Engine configuration
├── Gemfile                           # Engine dependencies
└── user_management.gemspec           # Gem specification
```

## Usage in MPA

The engine is mounted in the main application at `/user_management`.

## Development

When developing this engine:
1. Add routes in `config/routes.rb`
2. Create controllers in `app/controllers/user_management/`
3. Create models in `app/models/user_management/`
4. Add dependencies to the gemspec or Gemfile

## Testing

```bash
cd packages/user_management
bundle install
bundle exec rspec  # or your test framework
```
