module IncludeHandler
  extend ActiveSupport::Concern
  include ActiveModel::Model

  included do
    before_filter :init_includes
    
    def include_data
      if params[:include].present?
        if validate_include(@include_relationships,params[:include])
          return {include: params[:include].split(',').map(&:to_sym).flatten}
        else
          raise 'Invalid parameters for include.'
        end

      else
        return {}
      end
    end

    def validate_include(allowed_include, requested_include)
      queried_params = requested_include.split(',').map(&:to_sym).flatten
      length = ([allowed_include.values].flatten & queried_params).length
      length == [queried_params].flatten.length && [queried_params].flatten.length <= 4
    end
  end
  
end