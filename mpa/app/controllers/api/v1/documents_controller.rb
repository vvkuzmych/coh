module Api
  module V1
    class DocumentsController < Api::BaseController
      # GET /api/v1/documents
      def index
        # Pagination
        page = params[:page] || 1
        per_page = [params[:per_page]&.to_i || 20, 100].min  # max 100 per page
        
        # Filtering & Search
        query = params[:q] || params[:search] || '*'
        status_filter = params[:status] || params.dig(:filter, :status)
        
        # Sorting (use _score by default for relevance)
        sort_by = params[:sort_by] || '_score'
        order = params[:order] || 'desc'
        
        # Call OpenSearch service
        result = Opensearch::DocumentSearcher.new(
          query: query,
          status: status_filter,
          page: page,
          per_page: per_page,
          sort_by: sort_by,
          order: order
        ).call
        
        # Serialize documents
        documents = result[:documents].map { |doc| DocumentSerializer.new(doc).as_json }
        
        # Build meta
        meta = {
          total_count: result[:total],
          current_page: page.to_i,
          per_page: per_page,
          total_pages: (result[:total].to_f / per_page).ceil
        }
        
        render_success(documents, meta: meta)
      rescue Opensearch::DocumentSearcher::SearchError => e
        render_error(
          'Search failed',
          status: :internal_server_error,
          errors: [e.message]
        )
      end
      
      # GET /api/v1/documents/:id
      def show
        document = Opensearch::DocumentFetcher.new(params[:id]).call
        
        render_success(DocumentSerializer.new(document).as_json)
      rescue Opensearch::DocumentFetcher::DocumentNotFoundError => e
        render_error(
          'Document not found',
          status: :not_found,
          errors: [e.message]
        )
      rescue Opensearch::DocumentFetcher::DocumentFetchError => e
        render_error(
          'Failed to fetch document',
          status: :internal_server_error,
          errors: [e.message]
        )
      end
    end
  end
end
