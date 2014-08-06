class UsersController < ApplicationController
  before_action :signed_in_user,  only: [:show, :edit, :update]
  before_action :correct_user,    only: [:show, :edit, :update]
  before_action :editor,          only: :index
  before_action :admin_user,      only: :destroy

  def index
    @users = User.all
  end

  def show

    params[:n] = 100 if params[:n].blank?
    n = params[:n]
    n = 9999999 if params[:n] == "all"

    @user = User.find(params[:id])
    @observations = Observation.where('user_id IS ?', @user.id)

    if signed_in? && current_user.admin?
    elsif signed_in? && current_user.editor?
    elsif signed_in? && current_user.contributor?
      @observations = @observations.where(['observations.private IS ? OR (observations.user_id IS ? AND observations.private IS ?)', false, current_user.id, true])
    else
      @observations = @observations.where(['observations.private IS ?', false])
    end

    respond_to do |format|
      format.html {
        @observations = @observations.limit(n)
      }
      format.csv {
        if request.url.include? 'resources.csv'
          csv_string = get_resources_csv(@observations, "", "")
          filename = 'resources'
        else
          csv_string = get_main_csv(@observations, "", "")
          filename = 'data'
        end
        send_data csv_string, 
          :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
          :disposition => "attachment; filename=#{filename}_#{Date.today.strftime('%Y%m%d')}.csv"
      }

      format.zip{
        send_zip(@observations, 'data.csv', "", "")
      }

    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to Coral Traits"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    #params[:user].delete(:password) if params[:user][:password].blank?
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:danger] = "User destroyed."
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin, :contributor, :editor, :password_reset_token, :datetime)
    end

    # Before filters
  end
