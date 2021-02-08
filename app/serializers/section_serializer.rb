class SectionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :page_id, :name, :position, :visible, :content_type, :content, :created_at, :updated_at 
end
