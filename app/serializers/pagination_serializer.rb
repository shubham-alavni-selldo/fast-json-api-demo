class PaginationSerializer
  attr_accessor :options
  
  def initialize(object, options={})
    meta_key = options[:meta_key] || :meta
    @options = options
    @options[meta_key] = {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total_count: object.total_count
    } if object.try(:current_page).present?
  end

  def get_meta
    options
  end
  
end