class DocumentSerializer
  def initialize(document)
    @document = document
  end
  
  def as_json
    attributes = {
      title: @document['title'] || @document[:title],
      content: @document['content'] || @document[:content],
      status: @document['status'] || @document[:status]
    }
    
    # Add created_at only if present in document
    created_at = @document['created_at'] || @document[:created_at]
    attributes[:created_at] = format_timestamp(created_at) if created_at
    
    {
      id: @document['_id'] || @document[:id],
      type: 'document',
      attributes: attributes
    }
  end
  
  private
  
  def format_timestamp(timestamp)
    return nil unless timestamp
    
    if timestamp.is_a?(String)
      Time.parse(timestamp).iso8601
    elsif timestamp.respond_to?(:iso8601)
      timestamp.iso8601
    else
      timestamp.to_s
    end
  rescue
    timestamp.to_s
  end
end
