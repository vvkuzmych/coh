class ApplicationRecord < ActiveRecord::Base
  include Searchable
  primary_abstract_class
end
