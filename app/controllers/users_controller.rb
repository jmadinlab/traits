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
      @observations = Observation.where(['observations.user_id IS ? AND observations.private IS ?', @user.id, false]).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").limit(n)
      end
      
      if signed_in? && current_user.contributor?
        @observations = Observation.where(['observations.user_id IS ? AND (observations.private IS ? OR (observations.user_id IS ? AND observations.private IS ?))', @user.id, false, current_user.id, true]).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").limit(n)
      end

      if signed_in? && current_user.admin?
        @observations = Observation.where(:user_id => @user.id).includes(:coral).joins(:measurements).where('value LIKE ?', "%#{params[:search]}%").limit(n)
      end
    
      respond_to do |format|
        format.html
        format.csv { 

          csv_string = get_main_csv(@observations)
          send_data csv_string, 
            :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
            :disposition => "attachment; filename=user_#{Date.today.strftime('%Y%m%d')}.csv"


          '''
          csv_string = CSV.generate do |csv|
            csv << ["observation_id", "access", "enterer", "coral", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_name", "standard_unit", "value", "precision", "precision_type", "precision_upper", "replicates"]
            @observations.each do |obs|
        	    obs.measurements.each do |mea|
                if obs.location.present?
                  loc = obs.location.location_name
                  lat = obs.location.latitude
                  lon = obs.location.longitude
                  if obs.location.id == 1
                    lat = ""
                    lon = ""
                  end
                else
                  loc = ""
                  lat = ""
                  lon = ""
                end
                if obs.private == true
                  acc = 0
                else
                  acc = 1
                end
                csv << [obs.id, acc, obs.user_id, obs.coral.coral_name, loc, lat, lon, obs.resource_id, mea.id, mea.trait.trait_name, mea.standard.standard_unit, mea.value, mea.precision, mea.precision_type, mea.precision_upper, mea.replicates]
              end
            end
          end
          '''
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
