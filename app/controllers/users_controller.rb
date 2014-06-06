class UsersController < ApplicationController
  before_action :signed_in_user,  only: [:edit, :update, :show]
  before_action :contributor,     only: :index
  before_action :correct_user,    only: [:edit, :update]
  before_action :admin_user,      only: :destroy

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])

    if signed_in? && current_user.contributor?
      if params[:n].blank?
        params[:n] = 10
      end
    
      n = params[:n]
    
      if params[:n] == "all"
        n = 9999999
      end

      if !signed_in? | (signed_in? && (!current_user.admin? | !current_user.contributor?))
      @observations = Observation.where(['observations.user_id IS ? AND observations.private IS ?', @user.id, false]).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").uniq.limit(n)
      end
      
      if signed_in? && current_user.contributor?
        @observations = Observation.where(['observations.user_id IS ? AND (observations.private IS ? OR (observations.user_id IS ? AND observations.private IS ?))', @user.id, false, current_user.id, true]).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").uniq.limit(n)
      end

      if signed_in? && current_user.admin?
        @observations = Observation.where(:user_id => @user.id).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").uniq.limit(n)
      end
    
      respond_to do |format|
        format.html
        format.csv { 

          csv_string = get_main_csv(@observations)
          send_data csv_string, 
            :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
            :disposition => "attachment; filename=user_#{Date.today.strftime('%Y%m%d')}.csv"

        }

        format.zip{
          send_zip(@observations, 'users.csv')
        }

      end
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
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :admin, :contributor)
    end

    # Before filters
  end
