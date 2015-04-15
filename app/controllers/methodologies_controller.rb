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
      order_by :methodology_name_sortable, :asc
      
      if params[:all]
        paginate page: params[:page], per_page: 9999
      else
        paginate page: params[:page]
      end
    end
    @methodologies = @search.results

  	respond_to do |format|
      format.html
      format.csv { send_data Methodology.all.to_csv }
      
    end    
  end

  def show

    @observations = Observation.where(:id => @methodology.measurements.map(&:observation_id))
    @observations = observation_filter(@observations)

    respond_to do |format|
      format.html { @observations = @observations.paginate(page: params[:page]) }
      format.csv { download_observations(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
      format.zip{ send_zip(@observations, params[:taxonomy], params[:contextual] || "on", params[:global]) }
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

    if params[:checked]
      @observations = Observation.where(:id => Measurement.where(:methodology_id => params[:checked]).map(&:observation_id))
      @observations = observation_filter(@observations)
    else
      @observations = []
    end

    send_zip(@observations, params[:taxonomy], params[:contextual], params[:global])        
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
  		params.require(:methodology).permit(:methodology_name, :user_id, :method_description, :traits_attributes)
  	end
end