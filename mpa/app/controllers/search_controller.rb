# Search Controller for OpenSearch integration
class SearchController < ApplicationController
  def index
    # Show search form
  end

  def search
    @query = params[:q]
    @status = params[:status]
    
    if @query.blank?
      handle_empty_query
      return
    end

    perform_search
  end

  private

  def handle_empty_query
    @documents = []
    @total = 0
    flash.now[:alert] = "Please enter a search query"
    render :index
  end

  def perform_search
    result = Opensearch::DocumentSearcher.new(
      query: @query,
      status: @status
    ).call

    @documents = result[:documents]
    @total = result[:total]
    
    set_flash_message
    render :index
  rescue Opensearch::DocumentSearcher::SearchError => e
    handle_search_error(e)
  end

  def set_flash_message
    if @documents.empty?
      flash.now[:notice] = "No documents found for '#{@query}'"
    else
      flash.now[:success] = "Found #{@total} document(s)"
    end
  end

  def handle_search_error(error)
    Rails.logger.error("Search error: #{error.message}")
    @documents = []
    @total = 0
    flash.now[:alert] = "Search error: #{error.message}"
    render :index
  end
end
