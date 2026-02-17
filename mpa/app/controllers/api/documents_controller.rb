module Api
  class DocumentsController < ApplicationController
    # GET /api/documents/:id
    def show
      document = Opensearch::DocumentFetcher.new(params[:id]).call
      
      render json: { 
        success: true,
        document: document 
      }
    rescue Opensearch::DocumentFetcher::DocumentNotFoundError => e
      render json: { 
        success: false,
        error: e.message 
      }, status: :not_found
    rescue Opensearch::DocumentFetcher::DocumentFetchError => e
      render json: { 
        success: false,
        error: e.message 
      }, status: :internal_server_error
    end

    # GET /api/documents
    def index
      result = Opensearch::DocumentSearcher.new(
        query: params[:q] || '*',
        status: params[:status]
      ).call

      render json: {
        success: true,
        total: result[:total],
        documents: result[:documents]
      }
    rescue Opensearch::DocumentSearcher::SearchError => e
      render json: { 
        success: false,
        error: e.message 
      }, status: :internal_server_error
    end
  end
end
