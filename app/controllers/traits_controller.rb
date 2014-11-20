class TraitsController < ApplicationController

  # before_action :signed_in_user
  before_action :editor, except: [:index, :show, :export]
  before_action :set_trait, only: [:show, :edit, :update, :destroy]
  before_action :admin_user, only: :destroy

  # GET /traits
  # GET /traits.json
  def index
    # @traits = Trait.search(params[:search])

    pp = 15
    pp = 999 if params[:pp]

    @search = Trait.search do
      fulltext params[:search]
      paginate page: params[:page], per_page: pp
    end
    
    if params[:search]
      @traits = @search.results
    else
      @traits = Trait.all.paginate(:page=> params[:page], :per_page => pp)
    end

    respond_to do |format|
      format.html
      format.csv { send_data @traits.to_csv }
    end    
  end

  def export

    if !signed_in? | (signed_in? && (!current_user.admin? | !current_user.contributor?))
      @observations = Observation.where(:private => false).joins(:measurements).where(:measurements => {:trait_id => params[:checked]})        
    end
    
    if signed_in? && current_user.contributor? & !current_user.admin?
      @observations = Observation.where(['observations.private IS ? OR (observations.user_id IS ? AND observations.private IS ?)', false, current_user.id, true]).joins(:measurements).where(:measurements => {:trait_id => params[:checked]})
    end

    if signed_in? && current_user.admin?
      @observations = Observation.joins(:measurements).where(:measurements => {:trait_id => params[:checked]})        
    end
    
    # csv_string = get_main_csv(@observations, params[:contextual], params[:global])

    send_zip(@observations, 'traits.csv', params[:taxonomy], params[:contextual], params[:global])
      

    # send_data csv_string, 
    #  :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
    #  :disposition => "attachment; filename=ctdb_#{Date.today.strftime('%Y%m%d')}.csv"
       
  end

  # GET /traits/1
  # GET /traits/1.json
  def show

    if params[:coral_id]
      @coral = Coral.find(params[:coral_id])
      @observations = Observation.includes(:coral).joins(:measurements).where('observations.coral_id = ? AND measurements.trait_id = ?', @coral.id, @trait.id)
    else
      @observations = Observation.joins(:measurements).where('measurements.trait_id = ?', @trait.id)
    end

    if signed_in? && current_user.admin?
    elsif signed_in? && current_user.editor?
    elsif signed_in? && current_user.contributor?
      @observations = @observations.where(['observations.private IS false OR (observations.user_id = ? AND observations.private IS true)',  current_user.id])
    else
      @observations = @observations.where(['observations.private IS false'])
    end
    
    data_table = GoogleVisualr::DataTable.new

    if @trait.standard.standard_unit != "id" && @trait.standard.standard_unit != "text"
      if @trait.standard.standard_name == "Category" || @trait.standard.standard_name == "Binomial"
        data_table.new_column('string')
        data_table.new_column('number')

        @trait.measurements.collect(&:value).uniq.each do |i|
          data_table.add_row([i, @trait.measurements.where("value LIKE ?", i).size])
        end

#        data_table.sort(1)

        option = { width: 250, height: 250, legend: 'none' }
        @chart = GoogleVisualr::Interactive::PieChart.new(data_table, option)
      else
        data_table.new_column('number')
        data_table.new_column('number')

        p = 0
        # @trait.measurements.map(&:value).map{|v| v.to_d}.sort.reverse.each do |i|
        @trait.measurements.sort_by{ |a| a.value.to_d }.each do |i|
          if @trait.standard.standard_unit == "deg"
            data_table.add_row([p, i.to_d])
          else
            data_table.add_row([p, i.value.to_d])
          end            
          p = p + 1
        end

        option = { width: 250, height: 250, legend: 'none', :vAxis => { :title => "#{@trait.trait_name}" }, :hAxis => { textPosition: 'none' } }
        @chart = GoogleVisualr::Interactive::ScatterChart.new(data_table, option)
        # @chart.add_listener("select", "function(e) { EventHandler(e, chart, data_table) }")
      end
   end

    # @data_table = data_table

    respond_to do |format|
      format.html {
        @observations = @observations.paginate(:page=> params[:page], :per_page => 20)
      }
      format.csv {
        if request.url.include? 'resources.csv'
          csv_string = get_resources_csv(@observations)
          filename = 'resources'
        else
          csv_string = get_main_csv(@observations, "", "", "")
          filename = 'observations'
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

  # GET /traits/new
  def new
    @trait = Trait.new
  end

  # GET /traits/1/edit
  def edit
  end

  # POST /traits
  # POST /traits.json
  def create
    @trait = Trait.new(trait_params)
    methodology_ids =  params[:trait][:methodologies_attributes]
    traitvalue_ids =  params[:trait][:traitvalues_attributes]

    if not methodology_ids.nil?
      methodology_ids.keys().each do |k|
        methodology = Methodology.find(methodology_ids[k]["id"])
        @trait.methodologies << methodology if methodology_ids[k]["_destroy"] != "1" and not @trait.methodologies.include? methodology
      end
    end

    if @trait.save
      redirect_to @trait, flash: {success: "Trait was successfully created." }
    else
      render action: 'new' 
    end
  end

  # PATCH/PUT /traits/1
  # PATCH/PUT /traits/1.json
  def update
    methodology_ids =  params[:trait][:methodologies_attributes]
    traitvalue_ids =  params[:trait][:traitvalues_attributes]

    @trait.methodologies.delete_all()
    #@trait.traitvalues.delete_all()

    if not methodology_ids.nil?
      methodology_ids.keys().each do |k|
        method = Methodology.find(methodology_ids[k]["id"])
        @trait.methodologies << method if ((methodology_ids[k]["_destroy"] != "1") and (not @trait.methodologies.include? method))
        
      end
    end
    
    
    if @trait.update(trait_params)
      redirect_to @trait, flash: {success: "Trait was successfully updated." }
    else
      render action: 'edit'
    end
  end

  # DELETE /traits/1
  # DELETE /traits/1.json
  def destroy
    @trait.destroy
    respond_to do |format|
      format.html { redirect_to traits_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_trait
      @trait = Trait.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trait_params
      params.require(:trait).permit(:trait_name, :trait_description, :trait_class, :value_range, :standard_id, :user_id, :approval_status, :release_status, :methodologies, traitvalues_attributes: [:id, :value_name, :value_description, :_destroy])
    end
end


