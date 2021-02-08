class PageSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :subject_id, :name, :permalink, :position, :visible, :created_at, :updated_at
  has_many :sections

  attribute :subject_name do |object|
    object.try(:subject).try(:name)
  end
  
end
