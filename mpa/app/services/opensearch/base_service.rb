module Opensearch
  class BaseService
    class ServiceError < StandardError; end

    def self.call(*args, **kwargs)
      new(*args, **kwargs).call
    end

    protected

    def opensearch_available?
      defined?(OPENSEARCH_CLIENT)
    end

    def ensure_opensearch!
      raise ServiceError, "OpenSearch client not initialized" unless opensearch_available?
    end
  end
end
