class PagesController < ApplicationController

  layout 'admin'

  before_action :confirm_logged_in
  # before_action :find_subject
  before_action :set_page_count, :only => [:new, :create, :edit, :update]

  def index
    logger.debug("*** Testing the logger. ***")
    @pages = Page.includes(:sections).where(filter_by "like").order(sort_by).page(page_number).per(page_size).references(:name)
    if @pages.present?
      payload = get_seriallized_object(@pages,nil,include_data)
      response = render_responder(payload)
    else
      response = render_no_record_found
    end
    response
  end

  def show
    @page = Page.find(params[:id])
  end

  def new
    @page = Page.new(:subject_id => @subject.id)
  end

  def create
    @page = Page.new(page_params)
    @page.subject = @subject
    if @page.save
      flash[:notice] = "Page created successfully."
      redirect_to(pages_path(:subject_id => @subject.id))
    else
      render('new')
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(page_params)
      flash[:notice] = "Page updated successfully."
      redirect_to(page_path(@page, :subject_id => @subject.id))
    else
      render('edit')
    end
  end

  def delete
    @page = Page.find(params[:id])
  end

  def destroy
    @page = Page.find(params[:id])
    @page.destroy
    flash[:notice] = "Page destroyed successfully."
    redirect_to(pages_path(:subject_id => @subject.id))
  end

  def init_columns
    @search_cols = {"Page" => [:name],"Section" => [:name]}
    @sort_cols = {"Page" => [:position]}
  end

  def init_includes
    @include_relationships = {"Page" => [:sections]}
  end

  private

  def page_params
    params.require(:page).permit(:name, :position, :visible, :permalink)
  end

  def find_subject
    @subject = Subject.find(params[:subject_id])
  end

  def set_page_count
    @page_count = @subject.pages.count
    if params[:action] == 'new' || params[:action] == 'create'
      @page_count += 1
    end
  end

end
