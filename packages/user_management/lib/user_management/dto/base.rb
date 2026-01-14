class UserManagement::Dto::Base
  class << self
    # Class method to define an attribute/method to read from the source object
    # Usage:
    #   dto_attribute :id
    #   dto_attribute :email do |value|
    #     value.downcase
    #   end
    def dto_attribute(attr, &block)
      @dto_attributes ||= []
      @dto_transformations ||= {}

      @dto_attributes << attr
      @dto_transformations[attr] = block if block_given?

      # Sanitize instance variable name (remove special characters like '?')
      ivar_name = "@#{attr.to_s.gsub(/[?!]/, '')}"

      # Define reader method
      define_method(attr) do
        instance_variable_get(ivar_name)
      end

      # Re-define initialize to include all attributes
      define_initialize_method
    end

    # Get the list of all defined attributes
    def attribute_names
      @dto_attributes || []
    end

    private

    def define_initialize_method
      transformations = @dto_transformations || {}

      class_eval do
        define_method(:initialize) do |source_object|
          # Read all attributes from the source object (model or hash)
          self.class.attribute_names.each do |attr|
            value = if source_object.respond_to?(attr)
              source_object.public_send(attr)
            elsif source_object.is_a?(Hash)
              source_object[attr] || source_object[attr.to_s]
            end

            # Apply transformation if defined
            transformation = transformations[attr]
            value = transformation.call(value) if transformation

            # Sanitize instance variable name (remove special characters like '?')
            ivar_name = "@#{attr.to_s.gsub(/[?!]/, '')}"
            instance_variable_set(ivar_name, value)
          end
        end
      end
    end
  end

  # Instance method to convert DTO to hash
  # Includes both base attributes and computed attributes
  def to_h
    self.class.attribute_names.each_with_object({}) do |attr, hash|
      hash[attr] = public_send(attr)
    end
  end

  # Instance method to convert DTO to JSON
  def to_json(*args)
    to_h.to_json(*args)
  end

  # Instance method for nice inspection
  def inspect
    attrs = self.class.attribute_names.map do |attr|
      "#{attr}=#{public_send(attr).inspect}"
    end.join(", ")

    "#<#{self.class.name} #{attrs}>"
  end
end
