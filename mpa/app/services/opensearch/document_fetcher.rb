module Opensearch
  class DocumentFetcher
    def initialize(document_id)
      @document_id = document_id
    end

    def call
      response = OPENSEARCH_CLIENT.get(
        index: 'test_documents',
        id: @document_id
      )

      build_document(response)
    rescue OpenSearch::Transport::Transport::Errors::NotFound
      raise DocumentNotFoundError, "Document with ID #{@document_id} not found"
    rescue => e
      Rails.logger.error("Error fetching document #{@document_id}: #{e.message}")
      raise DocumentFetchError, e.message
    end

    private

    def build_document(response)
      {
        id: response['_id'],
        title: response['_source']['title'],
        content: response['_source']['content'],
        status: response['_source']['status'],
        score: response['_score']
      }
    end

    class DocumentNotFoundError < StandardError; end
    class DocumentFetchError < StandardError; end
  end
end
