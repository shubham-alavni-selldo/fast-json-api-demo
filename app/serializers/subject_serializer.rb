class SubjectSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :position, :visible, :created_at, :updated_at

  has_many :pages
  has_many :sections
end
