# OpenSearch Client Configuration

require 'opensearch'

OPENSEARCH_CLIENT = OpenSearch::Client.new(
  host: ENV.fetch('OPENSEARCH_URL', 'http://localhost:9200'),
  log: Rails.env.development?,
  retry_on_failure: 3,
  request_timeout: 30
)

# Test connection
if Rails.env.development?
  begin
    info = OPENSEARCH_CLIENT.info
    Rails.logger.info "✅ OpenSearch connected: #{info['version']['distribution']} #{info['version']['number']}"
  rescue => e
    Rails.logger.warn "⚠️  OpenSearch not available: #{e.message}"
  end
end
