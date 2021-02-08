class ApplicationController < ActionController::Base
  include ApiHandler
  include IndexHandler
  include IncludeHandler

  protect_from_forgery with: :exception

  private

  def confirm_logged_in
    unless session[:user_id]
      flash[:notice] = "Please log in."
      redirect_to(access_login_path)
      # redirect_to prevents requested action from running
    end
  end

  def init_columns
    
  end

  def init_includes
  end

end
