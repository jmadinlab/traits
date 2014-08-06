class MethodologiesController < ApplicationController

  before_action :contributor, except: [:index, :show, :export]
  before_action :set_methodology, only: [:show, :edit, :update, :destroy, :remove_trait]
  before_action :admin_user, only: :destroy


  # before_action :signed_in_user
  # before_action :contributor, only: [:create]
  # before_action :set_methodology, only: [:show, :edit, :update, :destroy, :remove_trait]

  def new
  	@methodology = Methodology.new
  end

  def create
  	@methodology = Methodology.new(methodology_params)
  	
    trait_ids =  params[:methodology][:traits_attributes]
    puts "testing methodologies"
    puts trait_ids["0"]["id"]
    if trait_ids["0"]["id"] != ""
    	trait_ids.keys().each do |k|
    		#puts id
    		#puts val
        trait = Trait.find(trait_ids[k]["id"]) 
    		@methodology.traits << trait if trait_ids[k]["_destroy"] != "1" and not @methodology.traits.include? trait
    	end
    end

  	#@traits = Trait.find(methodology_params[:traits_attributes])

  	#@methodology.traits << @traits
  	if @methodology.save
      redirect_to methodologies_path, flash: {success: "Methodology was successfully created." }
    else
      render action: 'new' 
    end
  end

  def index
   @search = Methodology.search do
      fulltext params[:search]
    end
    
    if params[:search]
      @methodologies = @search.results
    else
      @methodologies = Methodology.all
    end

    @methodologies = @methodologies.sort_by{|l| l[:id]} if params[:sort] == "id"
    @methodologies = @methodologies.sort_by{|l| l[:methodology_name]} if params[:sort] == "name"


  	respond_to do |format|
      format.html
      format.csv { send_data @methodologies.to_csv }
      
    end    
  end

  def show

    params[:n] = 100 if params[:n].blank?
    n = params[:n]
    n = 9999999 if params[:n] == "all"

    @observations = Observation.where(:id => @methodology.measurements.map(&:observation_id))

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


  def edit
  end

  def update
    trait_ids =  params[:methodology][:traits_attributes]
    @methodology.traits.delete_all()

    trait_ids.keys().each do |k|
      #puts id
      #puts val
      
        trait = Trait.find(trait_ids[k]["id"]) 
        @methodology.traits << trait if trait_ids[k]["_destroy"] != "1" and not @methodology.traits.include? trait
      
    end

    if @methodology.update(methodology_params)
      redirect_to @methodology, flash: {success: "Methodology was successfully updated." }
    else
      render action: 'edit'
    end
  end

  def destroy
    @methodology.destroy
    respond_to do |format|
      format.html { redirect_to methodologies_path }
      format.json { head :no_content }
    end
  end

  def remove_trait
  	trait = Trait.find(params[:trait_id])
  	if @methodology.traits.delete(trait)
  		redirect_to @methodology, flash: {success: "Trait Removed"}
  	else
  		redirect_to @methodology, flash: {alert: "Cannot remove Trait"}
  	end
  end

  def export
    checked = params[:checked]
      
    if signed_in? && current_user.contributor?
      if current_user.admin?
        @observations = Observation.where(:id => Measurement.where(:methodology_id => params[:checked]).map(&:observation_id))
      else

        @observations = Observation.where("(private = 'f' or (private = 't' and user_id = ?))", current_user.id).where(:id => Measurement.where(:methodology_id => params[:checked]).map(&:observation_id))
      end
    else
      @observations = Observation.where(:private => false).where(:id => Measurement.where(:methodology_id => params[:checked]).map(&:observation_id))        
    end        
    
    csv_string = get_main_csv(@observations)

    send_data csv_string, 
      :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
      :disposition => "attachment; filename=ctdb_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end


  # def export
  #   checked = params[:checked]
  #   methodologies = Methodology.where(:id => params[:checked])

  #   csv_string = CSV.generate do |csv|
  #     csv << ["methodology_id", "methodology_name", "method_description"]
  #     methodologies.each do |method|
  #       csv << [method.id, method.methodology_name, method.method_description]
  #     end
  #  	end

  #   send_data csv_string, 
  #     :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
  #     :disposition => "attachment; filename=methodologies_#{Date.today.strftime('%Y%m%d')}.csv"
          
  # end


  private
  	def set_methodology
      @methodology = Methodology.find(params[:id])
    end
  	
  	def methodology_params
  		params.require(:methodology).permit(:methodology_name, :method_description, :traits_attributes)
  	end
end