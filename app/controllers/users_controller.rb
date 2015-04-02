class UsersController < ApplicationController
  before_action :signed_in_user,  only: [:show, :edit, :update]
  before_action :correct_user,    only: [:show, :edit, :update]
  before_action :editor,          only: :index
  before_action :admin_user,      only: :destroy

  def index
    @users = User.all
  end

  def show

    params[:n] = 20 if params[:n].blank?
    n = params[:n]
    n = 9999999 if params[:n] == "all"

    @user = User.find(params[:id])
    @observations = Observation.where('user_id = ?', @user.id)
    @observations = observation_filter(@observations)
    @observations = @observations.order('created_at DESC')

    respond_to do |format|
      format.html { @observations = @observations.paginate(page: params[:page]) }
      format.csv { download_observations(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
      format.zip{ send_zip(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      
      SignUpMailer.acknowledge(@user).deliver
      
      flash[:success] = "Welcome to the " + ENV["SITE_NAME"]
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


  def edit_multiple
    @observations = Observation.find(params[:obs_ids])
  end

  def update_multiple
    User.where(:id => params[:ids]).update_all(:contributor => false)
    User.where(:id => params[:contrib_true_ids]).update_all(:contributor => true)
    User.where(:id => params[:ids]).update_all(:editor => false)
    User.where(:id => params[:editor_true_ids]).update_all(:contributor => true)
    User.where(:id => params[:editor_true_ids]).update_all(:editor => true)
    User.where(:id => params[:ids]).update_all(:admin => false)
    User.where(:id => params[:admin_true_ids]).update_all(:contributor => true)
    User.where(:id => params[:admin_true_ids]).update_all(:admin => true)
    User.where(:id => params[:admin_true_ids]).update_all(:editor => true)

    redirect_to users_path, flash: {success: "Privileges updated." }
  end




  private

    def user_params
      params.require(:user).permit(:name, :last_name, :institution, :email, :password, :password_confirmation, :admin, :contributor, :editor, :password_reset_token, :datetime)
    end

    # Before filters
  end
