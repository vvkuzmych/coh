# Searchable concern for OpenSearch integration
#
# Usage:
#   class Document < ApplicationRecord
#     include Searchable
#   end

module Searchable
  extend ActiveSupport::Concern

  included do
    after_commit :index_document, on: [:create, :update]
    after_commit :remove_document, on: :destroy
  end

  def index_document
    return unless defined?(OPENSEARCH_CLIENT)
    
    OPENSEARCH_CLIENT.index(
      index: self.class.index_name,
      id: id,
      body: as_indexed_json
    )
  rescue => e
    Rails.logger.error("Failed to index #{self.class.name} ##{id}: #{e.message}")
  end

  def remove_document
    return unless defined?(OPENSEARCH_CLIENT)
    
    OPENSEARCH_CLIENT.delete(
      index: self.class.index_name,
      id: id
    )
  rescue OpenSearch::Transport::Transport::Errors::NotFound
    # Document not found in index, it's ok
  rescue => e
    Rails.logger.error("Failed to remove #{self.class.name} ##{id}: #{e.message}")
  end

  # Override this in your model
  def as_indexed_json
    as_json
  end

  class_methods do
    def index_name
      "#{Rails.env}_#{name.underscore.pluralize}"
    end

    def create_index!
      return unless defined?(OPENSEARCH_CLIENT)
      
      OPENSEARCH_CLIENT.indices.create(
        index: index_name,
        body: index_settings
      )
      Rails.logger.info "✅ Created index: #{index_name}"
    rescue OpenSearch::Transport::Transport::Errors::BadRequest => e
      Rails.logger.warn "Index #{index_name} already exists"
    end

    def delete_index!
      return unless defined?(OPENSEARCH_CLIENT)
      
      OPENSEARCH_CLIENT.indices.delete(index: index_name)
      Rails.logger.info "✅ Deleted index: #{index_name}"
    rescue OpenSearch::Transport::Transport::Errors::NotFound
      Rails.logger.warn "Index #{index_name} not found"
    end

    def refresh_index!
      return unless defined?(OPENSEARCH_CLIENT)
      
      OPENSEARCH_CLIENT.indices.refresh(index: index_name)
    end

    # Override this in your model
    def index_settings
      {
        settings: {
          number_of_shards: 1,
          number_of_replicas: 0
        },
        mappings: {
          properties: {
            created_at: { type: 'date' },
            updated_at: { type: 'date' }
          }
        }
      }
    end

    # Simple search
    def search(query, options = {})
      return [] unless defined?(OPENSEARCH_CLIENT)
      
      response = OPENSEARCH_CLIENT.search(
        index: index_name,
        body: {
          query: query,
          size: options[:size] || 20,
          from: options[:from] || 0,
          sort: options[:sort] || [{ _score: 'desc' }]
        }
      )

      hits = response['hits']['hits']
      
      if options[:include_score]
        hits.map { |hit| { record: find(hit['_id']), score: hit['_score'] } }
      else
        hits.map { |hit| find(hit['_id']) }
      end
    rescue => e
      Rails.logger.error("Search failed: #{e.message}")
      []
    end

    # Bulk index
    def reindex_all!
      return unless defined?(OPENSEARCH_CLIENT)
      
      count = 0
      find_each do |record|
        record.index_document
        count += 1
      end
      
      refresh_index!
      Rails.logger.info "✅ Reindexed #{count} #{name.pluralize}"
      count
    end
  end
end
