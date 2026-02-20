module Api
  class BaseController < ActionController::API
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_validation_error
    
    private
    
    # Success response helper
    def render_success(data, status: :ok, meta: {})
      render json: {
        success: true,
        data: data,
        meta: meta
      }, status: status
    end
    
    # Error response helper
    def render_error(message, status: :bad_request, errors: [])
      render json: {
        success: false,
        error: {
          message: message,
          details: errors
        }
      }, status: status
    end
    
    # 404 Not Found
    def render_not_found(exception)
      render_error(
        'Resource not found',
        status: :not_found
      )
    end
    
    # 422 Validation Error
    def render_validation_error(exception)
      render_error(
        'Validation failed',
        status: :unprocessable_entity,
        errors: exception.record.errors.full_messages
      )
    end
    
    # Pagination meta
    def pagination_meta(collection)
      {
        current_page: collection.current_page,
        next_page: collection.next_page,
        prev_page: collection.prev_page,
        total_pages: collection.total_pages,
        total_count: collection.total_count,
        per_page: collection.limit_value
      }
    end
    
    # Apply filters to scope
    def apply_filters(scope, allowed_filters = {})
      return scope unless params[:filter].present?
      
      filters = params[:filter].permit(allowed_filters.keys)
      
      filters.each do |key, value|
        next if value.blank?
        
        filter_config = allowed_filters[key.to_sym]
        next unless filter_config
        
        case filter_config[:type]
        when :exact
          scope = scope.where(key => value)
        when :date_from
          scope = scope.where("#{key} >= ?", value)
        when :date_to
          scope = scope.where("#{key} <= ?", value)
        when :search
          columns = filter_config[:columns] || [key]
          conditions = columns.map { |col| "#{col} ILIKE ?" }.join(' OR ')
          values = [value].cycle(columns.size).map { |v| "%#{v}%" }
          scope = scope.where(conditions, *values)
        end
      end
      
      scope
    end
    
    # Apply sorting
    def apply_sorting(scope, allowed_columns = [])
      sort_by = params[:sort_by]&.to_s || 'created_at'
      order = params[:order]&.to_s || 'desc'
      
      return scope unless allowed_columns.include?(sort_by)
      return scope unless %w[asc desc].include?(order)
      
      scope.order("#{sort_by} #{order}")
    end
  end
end
