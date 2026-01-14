class UserManagement::Responses::DocumentResponse
  attr_reader :id, :title, :content, :user_id, :status, :storage_bytes, :created_at, :updated_at

  def initialize(data)
    @id = data["id"].to_i
    @title = data["title"]
    @content = data["content"]
    @user_id = data["userId"].to_i
    @status = data["status"]
    @storage_bytes = data["storageBytes"].to_i
    @created_at = data["createdAt"]
    @updated_at = data["updatedAt"]
  end

  def to_h
    {
      id: id,
      title: title,
      content: content,
      user_id: user_id,
      status: status,
      storage_bytes: storage_bytes,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
