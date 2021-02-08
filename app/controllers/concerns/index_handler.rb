module IndexHandler
  extend ActiveSupport::Concern
  include ActiveModel::Model

  included do
    before_filter :init_columns

    def filter_by(search_criteria)
      search_pattern = params[:filter][:search_pattern] rescue ''
      prepare_condition(search_pattern,search_criteria)
    end

    def sort_by
      sort_key =params[:sort] rescue nil
      if sort_key.present?
        sort_direction = (sort_key.count('-')>0 ? 'DESC' : 'ASC')
        sort_col = sort_key.gsub('-','')
      end
      if sort_col.present? && sort_direction.present?
        if validate_parameters(@sort_cols,sort_col)
          col = @sort_cols.select{|key, value|  value.include? sort_col.to_sym }.first
          klass = col.first.constantize
          sort_col = sort_col || 'created_at'
          sort_by = "#{klass.table_name}.#{sort_col}"
          sort_direction = sort_direction || 'ASC'
          # return order_condn = sanitize_sql("#{sort_by} #{sort_direction}", klass)
          return order_condn = send(:sanitize_sql,"#{sort_by} #{sort_direction}", klass)
        else
          raise 'Invalid parameters for sorting.'
        end
      elsif (@default_sort_cols.present? rescue false)
        col = @default_sort_cols.keys
        klass = col.first.constantize
        sort_col = @default_sort_cols.values.flatten.first
        sort_by = "#{klass.table_name}.#{sort_col}"
        sort_direction = 'DESC'
        # return order_condn = sanitize_sql("#{sort_by} #{sort_direction}", klass)
        return order_condn = send(:sanitize_sql,"#{sort_by} #{sort_direction}", klass)
      end
    end

    def page_size
      if (!params[:page][:size].blank? && params[:page][:size].to_i <= PAGESIZE_LIMIT rescue false)
        params[:page][:size]
      else
        DEFAULT_PAGE_SIZE
      end
    end

    def page_number
      ((params[:page][:number].blank? rescue true) ? DEFAULT_FIRST_PAGE : params[:page][:number])
    end

    private

    def prepare_condition(search_pattern,search_criteria)
      clause = []
      return if search_pattern.blank?
      search_patterns = search_pattern.is_a?(Array) ? search_pattern : ((search_pattern.is_a?(Hash) || search_pattern.is_a?(HashWithIndifferentAccess)) ? search_pattern.values : search_pattern.split(","))
      search_patterns.each{|search_p|
        @search_cols.each{|key, value|
          condn = []
          klass = key.to_s.constantize
          value.each{|attribute|
            condn << send("#{search_criteria}_clause",klass.table_name,attribute)
          }
          full_condn = condn.join(" or ")
          search_val = send("#{search_criteria}_pattern",search_p)
          # clause << klass.sanitize_sql([full_condn, search_pattern: search_val],klass)
          clause << klass.send(:sanitize_sql, [full_condn, search_pattern: search_val])
        } if search_p.present?
      }
      clause.join(" or ")
    end

    def like_clause(table_name, attribute)
      "#{table_name}.#{attribute} LIKE :search_pattern"
    end

    def eq_clause(table_name, attribute)
      "#{table_name}.#{attribute} = :search_pattern"
    end

    def in_clause(table_name, attribute)
      "#{table_name}.#{attribute} in (:search_pattern)"
    end

    def like_pattern(search_pattern)
      "%#{search_pattern}%"
    end

    def in_pattern(search_pattern)
      search_pattern
    end

    def eq_pattern(search_pattern)
      "#{search_pattern}"
    end

    def validate_parameters(allowed_params, queried_params)
      queried_params = [queried_params].map(&:to_sym).flatten
      length = ([allowed_params.values].flatten & queried_params).length
      length == [queried_params].flatten.length
    end

    def compile_queries(search_queries, operator)
      condition_statements = []
      condition_arguments = []

      search_queries.each do |condition_arr|
        condition_statements << condition_arr.first
        condition_arguments.concat(condition_arr[1..-1])
      end

      main_con = []
      combined_sql_with_operator = condition_statements.join(" #{operator} ")
      main_con << combined_sql_with_operator
      main_con.concat(condition_arguments)
    end
  end
end
