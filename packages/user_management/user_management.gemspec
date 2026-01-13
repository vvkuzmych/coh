require_relative "lib/user_management/version"

# Load environment variables from .env file if it exists (only if dotenv is available)
begin
  require "dotenv"
  Dotenv.load(File.expand_path(".env", __dir__)) if File.exist?(File.expand_path(".env", __dir__))
rescue LoadError
  # dotenv not yet installed, use default values from ENV.fetch fallbacks
end

Gem::Specification.new do |spec|
  spec.name        = "user_management"
  spec.version     = UserManagement::VERSION
  spec.authors     = [ ENV.fetch("GEM_AUTHOR_NAME", "Unknown Author") ]
  spec.email       = [ ENV.fetch("GEM_AUTHOR_EMAIL", "noreply@example.com") ]
  spec.homepage    = ENV.fetch("GEM_HOMEPAGE", "https://github.com/example/repo")
  spec.summary     = "User Management Engine for COH"
  spec.description = "Handles user data, profiles, and related functionality as a modular engine"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org - this is an internal engine
  spec.metadata["allowed_push_host"] = ENV.fetch("GEM_ALLOWED_PUSH_HOST", "https://rubygems.pkg.github.com/example")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = ENV.fetch("GEM_SOURCE_CODE_URI", spec.homepage)

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.1.2"
end
