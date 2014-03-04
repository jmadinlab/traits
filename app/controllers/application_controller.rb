class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  WillPaginate.per_page = 15

  def update_values
    @values = Trait.find(params[:trait_id]).value_range.split(',').map(&:strip)
    @standard = Standard.find(Trait.find(params[:trait_id]).standard_id)
  end
  
  # Before filters

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
      redirect_to(root_url) unless signed_in? && current_user.admin?
  end

  def contributor
      redirect_to(
        root_url,flash: {danger: "You need to be a contributor to access this area of the database." }
      ) unless signed_in? && current_user.contributor?
      
  end
  
end
