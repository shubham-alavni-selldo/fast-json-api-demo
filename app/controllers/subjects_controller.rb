class SubjectsController < ApplicationController

  layout 'admin'

  before_action :confirm_logged_in
  before_action :set_subject_count, :only => [:new, :create, :edit, :update]

  def index
    logger.debug("*** Testing the logger. ***")
    @subjects = Subject.includes(:pages,:sections).where(filter_by "like").order(sort_by).page(page_number).per(page_size).references(:name)
    if @subjects.present?
      payload = get_seriallized_object(@subjects,nil,include_data)
      response = render_responder(payload)
    else
      response = render_no_record_found
    end
    response
  end

  def show
    @subject = Subject.find(params[:id])
  end

  def new
    @subject = Subject.new({:name => 'Default'})
  end

  def create
    # Instantiate a new object using form parameters
    @subject = Subject.new(subject_params)
    # Save the object
    if @subject.save
      # If save succeeds, redirect to the index action
      flash[:notice] = "Subject created successfully."
      redirect_to(subjects_path)
    else
      # If save fails, redisplay the form so user can fix problems
      render('new')
    end
  end

  def edit
    @subject = Subject.find(params[:id])
  end

  def update
    # Find a new object using form parameters
    @subject = Subject.find(params[:id])
    # Update the object
    if @subject.update_attributes(subject_params)
      # If save succeeds, redirect to the show action
      flash[:notice] = "Subject updated successfully."
      redirect_to(subject_path(@subject))
    else
      # If save fails, redisplay the form so user can fix problems
      render('edit')
    end
  end

  def delete
    @subject = Subject.find(params[:id])
  end

  def destroy
    @subject = Subject.find(params[:id])
    @subject.destroy
    flash[:notice] = "Subject '#{@subject.name}' destroyed successfully."
    redirect_to(subjects_path)
  end

  def init_columns
    @search_cols = {"Subject" => [:name],"Section" => [:name]}
    @sort_cols = {"Subject" => [:position]}
  end

  def init_includes
    @include_relationships = {"Subject" => [:pages,:sections]}
  end

  private

  def subject_params
    params.require(:subject).permit(:name, :position, :visible, :created_at)
  end

  def set_subject_count
    @subject_count = Subject.count
    if params[:action] == 'new' || params[:action] == 'create'
      @subject_count += 1
    end
  end

end
