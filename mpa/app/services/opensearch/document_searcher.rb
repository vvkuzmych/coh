module Opensearch
  class DocumentSearcher
    DEFAULT_SIZE = 50

    def initialize(query:, status: nil, page: 1, per_page: DEFAULT_SIZE, sort_by: '_score', order: 'desc')
      @query = query
      @status = status
      @page = page.to_i
      @per_page = [per_page.to_i, 100].min  # max 100 per page
      @sort_by = sort_by
      @order = order
    end

    def call
      search_body = build_search_query
      
      response = OPENSEARCH_CLIENT.search(
        index: 'test_documents',
        body: search_body
      )

      parse_response(response)
    rescue => e
      Rails.logger.error("Error searching documents: #{e.message}")
      raise SearchError, e.message
    end

    private

    def build_search_query
      {
        query: build_query_clause,
        from: (@page - 1) * @per_page,
        size: @per_page,
        sort: build_sort_clause,
        highlight: highlight_config
      }
    end

    def build_query_clause
      base_query = {
        bool: {
          must: [query_match]
        }
      }

      # Build filters array
      filters = []
      filters << { term: { status: @status } } if @status.present?
      # Note: date filters removed as test_documents index doesn't have created_at field
      # Add when index mapping includes date fields

      base_query[:bool][:filter] = filters if filters.any?

      base_query
    end
    
    def build_sort_clause
      # Whitelist sortable fields (only fields that exist in OpenSearch mapping)
      allowed_fields = %w[title status _score]
      
      # If sort field doesn't exist in index, use relevance score
      if allowed_fields.include?(@sort_by)
        field = @sort_by
        direction = %w[asc desc].include?(@order) ? @order : 'desc'
        
        if field == '_score'
          [{ '_score' => { 'order' => direction } }]
        else
          [{ field => { 'order' => direction } }]
        end
      else
        # Default: sort by relevance score
        [{ '_score' => { 'order' => 'desc' } }]
      end
    end

    def query_match
      if @query == '*' || @query.blank?
        { match_all: {} }
      else
        {
          multi_match: {
            query: @query,
            fields: ['title^2', 'content'],
            fuzziness: 'AUTO'
          }
        }
      end
    end

    def highlight_config
      {
        fields: {
          title: {},
          content: { fragment_size: 150 }
        }
      }
    end

    def parse_response(response)
      {
        total: response['hits']['total']['value'],
        documents: map_documents(response['hits']['hits'])
      }
    end

    def map_documents(hits)
      hits.map do |hit|
        source = hit['_source']
        {
          _id: hit['_id'],
          id: hit['_id'],
          title: source['title'],
          content: source['content'],
          status: source['status'],
          created_at: source['created_at'],
          updated_at: source['updated_at'],
          score: hit['_score'],
          highlight: hit['highlight']
        }.compact
      end
    end

    class SearchError < StandardError; end
  end
end
