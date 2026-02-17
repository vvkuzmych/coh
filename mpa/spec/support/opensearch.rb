# RSpec configuration for OpenSearch testing
#
# Add to spec/rails_helper.rb:
#   require 'support/opensearch'

RSpec.configure do |config|
  # Setup OpenSearch indices before running tests
  config.before(:suite) do
    if defined?(OPENSEARCH_CLIENT)
      begin
        # Create test indices
        Document.create_index!
        puts "✅ Created OpenSearch test indices"
      rescue => e
        puts "⚠️  OpenSearch setup failed: #{e.message}"
      end
    else
      puts "⚠️  OpenSearch not available for testing"
    end
  end

  # Clean up after all tests
  config.after(:suite) do
    if defined?(OPENSEARCH_CLIENT)
      begin
        Document.delete_index!
        puts "✅ Deleted OpenSearch test indices"
      rescue => e
        # Index might not exist, ignore
      end
    end
  end

  # Refresh index after each test to make documents searchable
  config.after(:each) do
    if defined?(OPENSEARCH_CLIENT)
      begin
        Document.refresh_index!
      rescue => e
        # Ignore errors
      end
    end
  end

  # Helper method for testing search
  config.include Module.new {
    def wait_for_indexing(timeout: 2)
      sleep(timeout)
      Document.refresh_index! if defined?(OPENSEARCH_CLIENT)
    end
  }, type: :request
end
