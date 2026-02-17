module Opensearch
  class DocumentSearcher
    DEFAULT_SIZE = 50

    def initialize(query:, status: nil, size: DEFAULT_SIZE)
      @query = query
      @status = status
      @size = size
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
        size: @size,
        highlight: highlight_config
      }
    end

    def build_query_clause
      base_query = {
        bool: {
          must: [query_match]
        }
      }

      if @status.present?
        base_query[:bool][:filter] = [
          { term: { status: @status } }
        ]
      end

      base_query
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
        {
          id: hit['_id'],
          title: hit['_source']['title'],
          content: hit['_source']['content'],
          status: hit['_source']['status'],
          score: hit['_score'],
          highlight: hit['highlight']
        }
      end
    end

    class SearchError < StandardError; end
  end
end
