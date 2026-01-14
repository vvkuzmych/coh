class UserManagement::Responses::AccountResponse
  attr_reader :id, :name, :users_count, :documents_count, :total_storage_bytes, :created_at, :updated_at

  def initialize(data)
    @id = data["id"].to_i
    @name = data["name"]
    @users_count = data["usersCount"].to_i
    @documents_count = data["documentsCount"].to_i
    @total_storage_bytes = data["totalStorageBytes"].to_i
    @created_at = data["createdAt"]
    @updated_at = data["updatedAt"]
  end

  def to_h
    {
      id: id,
      name: name,
      users_count: users_count,
      documents_count: documents_count,
      total_storage_bytes: total_storage_bytes,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
