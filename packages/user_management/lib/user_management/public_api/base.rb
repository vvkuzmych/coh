class UserManagement::PublicApi::Base
  class << self
    # Define which model and DTO this API uses
    # Usage: configure model_class: "UserManagement::User", dto_class: UserManagement::Dto::User
    # Note: model_class can be a string to avoid eager loading
    def configure(model_class:, dto_class:)
      @model_class_name = model_class.is_a?(String) ? model_class : model_class.name
      @dto_class = dto_class
    end

    def model_class
      return @model_class_cached if defined?(@model_class_cached)

      if @model_class_name
        @model_class_cached = @model_class_name.constantize
      else
        raise "Model class not configured. Use: configure model_class: 'MyModel', dto_class: MyDto"
      end
    end

    def dto_class
      @dto_class || raise("DTO class not configured. Use: configure model_class: 'MyModel', dto_class: MyDto")
    end

    # Wrap a single model instance to DTO
    def wrap(model)
      return nil unless model

      dto_class.new(model)
    end

    # Wrap a collection of models to DTOs
    def wrap_collection(models)
      models.map { |model| wrap(model) }
    end

    # Common query methods

    # Find a single record by ID
    def find(id)
      model = model_class.find_by(id: id)
      wrap(model)
    end

    # Find a single record by attribute
    # Example: find_by(email: "user@example.com")
    def find_by(**attributes)
      model = model_class.find_by(**attributes)
      wrap(model)
    end

    # Get all records
    def all
      models = model_class.all
      wrap_collection(models)
    end

    # Get records matching conditions
    # Example: where(role: :admin)
    def where(**conditions)
      models = model_class.where(**conditions)
      wrap_collection(models)
    end

    # Count records
    def count
      model_class.count
    end

    # Count records matching conditions
    def count_where(**conditions)
      model_class.where(**conditions).count
    end

    # Check if any records exist
    def exists?(**conditions)
      model_class.exists?(**conditions)
    end

    # Get first N records
    def first(limit = 1)
      if limit == 1
        wrap(model_class.first)
      else
        wrap_collection(model_class.first(limit))
      end
    end

    # Get last N records
    def last(limit = 1)
      if limit == 1
        wrap(model_class.last)
      else
        wrap_collection(model_class.last(limit))
      end
    end

    # Pluck specific attributes (returns raw values, not DTOs)
    def pluck(*attributes)
      model_class.pluck(*attributes)
    end

    # Execute a custom query and wrap results
    # Example: query { model_class.where(active: true).order(:name) }
    def query(&block)
      models = block.call(model_class)
      wrap_collection(models)
    end

    # ========================================
    # CRUD Operations
    # ========================================

    # CREATE - Create a new record
    # Example: create(email: "user@example.com", first_name: "John")
    # Returns: DTO or nil if failed
    def create(**attributes)
      model = model_class.new(attributes)
      if model.save
        wrap(model)
      else
        nil
      end
    end

    # CREATE! - Create a new record (raises on error)
    # Example: create!(email: "user@example.com", first_name: "John")
    # Returns: DTO
    # Raises: ActiveRecord::RecordInvalid if validation fails
    def create!(**attributes)
      model = model_class.create!(attributes)
      wrap(model)
    end

    # UPDATE - Update an existing record by ID
    # Example: update(1, email: "newemail@example.com")
    # Returns: DTO or nil if not found/failed
    def update(id, **attributes)
      model = model_class.find_by(id: id)
      return nil unless model

      if model.update(attributes)
        wrap(model)
      else
        nil
      end
    end

    # UPDATE! - Update an existing record by ID (raises on error)
    # Example: update!(1, email: "newemail@example.com")
    # Returns: DTO
    # Raises: ActiveRecord::RecordNotFound if not found
    # Raises: ActiveRecord::RecordInvalid if validation fails
    def update!(id, **attributes)
      model = model_class.find(id)
      model.update!(attributes)
      wrap(model)
    end

    # UPDATE_BY - Update records matching conditions
    # Example: update_by({ role: :guest }, { status: :active })
    # Returns: Integer (number of records updated)
    def update_by(conditions, **attributes)
      model_class.where(conditions).update_all(attributes)
    end

    # DELETE - Delete a record by ID
    # Example: delete(1)
    # Returns: true if deleted, false if not found
    def delete(id)
      model = model_class.find_by(id: id)
      return false unless model

      model.destroy
      true
    end

    # DELETE! - Delete a record by ID (raises on error)
    # Example: delete!(1)
    # Returns: true
    # Raises: ActiveRecord::RecordNotFound if not found
    def delete!(id)
      model = model_class.find(id)
      model.destroy
      true
    end

    # DELETE_BY - Delete records matching conditions
    # Example: delete_by(role: :guest)
    # Returns: Integer (number of records deleted)
    def delete_by(**conditions)
      model_class.where(conditions).destroy_all.count
    end

    # DELETE_ALL - Delete all records (use with caution!)
    # Returns: Integer (number of records deleted)
    def delete_all
      model_class.destroy_all.count
    end

    # UPSERT - Create or update a record
    # Example: upsert({ email: "user@example.com" }, { first_name: "John" })
    # Returns: DTO
    def upsert(find_attributes, **update_attributes)
      model = model_class.find_or_initialize_by(find_attributes)
      model.assign_attributes(update_attributes)
      model.save
      wrap(model)
    end

    # Batch CREATE - Create multiple records
    # Example: batch_create([{ email: "a@test.com" }, { email: "b@test.com" }])
    # Returns: Array of DTOs
    def batch_create(attributes_array)
      models = attributes_array.map { |attrs| model_class.create(attrs) }
      wrap_collection(models.compact)
    end
  end
end
