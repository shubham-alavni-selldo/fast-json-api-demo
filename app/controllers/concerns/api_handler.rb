module ApiHandler
  extend ActiveSupport::Concern
  include ActiveModel::Model

  included do

    def get_seriallized_object(objects, klass_name = nil, options = {})
      plural_obj = (objects.kind_of?(ActiveRecord::Relation) || objects.kind_of?(Array))
      object = [objects].flatten.first
      klass = "#{object.class.name}Serializer".constantize if !klass_name.present?
      klass = "#{klass_name}".constantize if klass_name.present?
      serialized_obj = nil
      options[:params] ||= (options || {})
      if plural_obj
        options[:is_collection] = true
        meta = PaginationSerializer.new(objects,options).get_meta[:meta]
        options.merge!(:meta => meta)
      else
        options[:is_collection] = false
      end
      serialized_obj = klass.new(objects, options).serializable_hash

      return serialized_obj
    end

    def render_responder(payload)
      render json: {status: 'SUCCESS', response: payload}
    end

    def render_no_record_found
      render json: {status: 'SUCCESS', response: "Records not present"}
    end

  end
end