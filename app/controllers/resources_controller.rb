class ResourcesController < ApplicationController

  before_action :contributor, except: [:index, :show, :export, :update]
  before_action :admin_user, only: [:destroy, :expunge, :status]
  before_action :set_resource, only: [:show, :edit, :update, :destroy, :expunge, :doi, :duplicates]

  def index

    @search = Resource.search do
      fulltext params[:search]
      
      if params[:count]
        order_by :count_sortable, :desc
      else
        order_by :author_sortable, :asc
      end

      if params[:all]
        paginate page: params[:page], per_page: 9999
      else
        paginate page: params[:page]
      end
    end
    @resources = @search.results

    respond_to do |format|
      format.html
      format.csv { send_data @resources.to_csv }
    end    
  end

  def status

    @resources = Resource.where("doi_isbn IS NULL OR doi_isbn = ?", "").paginate(page: params[:page], per_page: 10)

    respond_to do |format|
      format.html
    end    
  end

  def show

    @primary = Observation.where('resource_id = ?', @resource.id)
    @secondary = Observation.where('resource_secondary_id = ?', @resource.id)

    @primary = observation_filter(@primary)
    @secondary = observation_filter(@secondary)

    @locations = Location.where("id IN (?) OR id IN (?)", @primary.map(&:location_id), @secondary.map(&:location_id))

    respond_to do |format|
      format.html {
        @primary = @primary.paginate(:page=> params[:page])
        @secondary = @secondary.paginate(:page=> params[:page])
      }
      format.csv { download_observations(@primary, params[:taxonomy], params[:contextual] || "on", params[:global]) }
      format.zip{ send_zip(@primary, params[:taxonomy], params[:contextual] || "on", params[:global]) }
    end

  end

  def duplicates

    @duplicates = Observation.joins(:measurements).select("specie_id, resource_id, location_id, trait_id, standard_id, value, array_agg(observation_id) as ids").where("resource_id = ?", params[:id]).where("trait_id NOT IN (?) AND value_type != 'raw_value'", Trait.where("trait_class = 'Contextual'").map(&:id)).group(:specie_id, :resource_id, :location_id, :trait_id, :standard_id, :value).having("count(*) > 1")

    respond_to do |format|
      format.html { }
      format.json { 
        render json: { dups: @duplicates.length }
      }
    end

  end

  # GET /resources/new
  def new
    @resource = Resource.new
  end

  def doi

    if @resource.doi_isbn.present?
      begin
        @doi = JSON.load(open("https://api.crossref.org/works/#{@resource.doi_isbn}"))
        if @doi["message"]["author"][0]["family"] == "Peresson"
          @doi = "Invalid"
        end
      rescue
        @doi = "Invalid"
      end
    end

    if (not @resource.doi_isbn.present? or @doi == "Invalid") and (@resource.resource_type == "paper" or @resource.resource_type.blank?)
      begin
        @sug = JSON.load(open("https://api.crossref.org/works?query=#{@resource.title.tr(" ", "+")}&rows=3"))
      rescue
        @sug = "Invalid"
      end        
    end

    render json: {
      sug: @sug, 
      doi: @doi
    }    

  end

  # GET /resources/1/edit
  def edit

    # if @resource.doi_isbn.present?
    #   begin
    #     @doi = JSON.load(open("https://api.crossref.org/works/#{@resource.doi_isbn}"))
    #     if @doi["message"]["author"][0]["family"] == "Peresson"
    #       @doi = "Invalid"
    #     end
    #   rescue
    #     @doi = "Invalid"
    #   end
    # end

    # if (not @resource.doi_isbn.present? or @doi == "Invalid") and (@resource.resource_type == "paper" or @resource.resource_type.blank?)
    #   begin
    #     @sug = JSON.load(open("https://api.crossref.org/works?query=#{@resource.title.tr(" ", "+")}&rows=3"))
    #   rescue
    #     @sug = "Invalid"
    #   end        
    # end
    
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)

    if @resource.doi_isbn.present?
      begin
        @doi = JSON.load(open("https://api.crossref.org/works/#{@resource.doi_isbn}"))
        if @doi["message"]["author"][0]["family"] == "Peresson"
          @doi = "Invalid"
          @resource.errors.add(:base, 'The oid is invalid')
        end
      rescue
        @doi = "Invalid"
        @resource.errors.add(:base, 'The oid is invalid')
      end
    end

    # puts @doi["message"].green

    if @doi and not @doi == "Invalid"
      authors = ""
      @doi["message"]["author"].each do |a|
        if a["family"].present?
          authors = authors + "#{a["family"].titleize}, "
        end
        if a["given"].present?
          authors = authors + "#{a["given"].titleize}, "
        end
      end

      @resource.author = authors
      @resource.year = @doi["message"]["issued"]["date-parts"][0][0]
      @resource.title = @doi["message"]["title"][0]
      @resource.journal = @doi["message"]["container-title"][0]
      @resource.volume_pages = @doi["message"]["volume"], @doi["message"]["page"]

    end

    if @resource.save
      if not @resource.doi_isbn.present? and (@resource.resource_type == "paper" or @resource.resource_type.blank?)
        redirect_to edit_resource_path(@resource), flash: {success: "Resource was successfully created. However, please enter a doi if possible (some possibilities listed below)" }
      else
        redirect_to @resource, flash: {success: "Resource was successfully created." }
      end
    else
      render action: 'new' 
    end
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update

    require 'uri'

    puts "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"
    puts @resource.to_json

    if params[:resource].blank?
      params[:resource] = @resource.attributes
    end

    puts "RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR"
    puts params[:resource]

    if params[:resource][:doi_isbn].present? and (params[:resource][:resource_type] == "paper" or params[:resource][:resource_type].blank?)
      begin
        @doi = JSON.load(open("https://api.crossref.org/works/#{params[:resource][:doi_isbn]}"))
        if @doi["message"]["author"][0]["family"] == "Peresson"
          @doi = "Invalid"
          @resource.errors.add(:base, 'The oid is invalid')
        end
      rescue
        @doi = "Invalid"
        @resource.errors.add(:base, 'The oid is invalid')
      end
    end


    if @doi and not @doi == "Invalid"
      authors = []
      @doi["message"]["author"].each do |a|
        if a["family"].present?
          authors << a["family"]
        end
        if a["given"].present?
          given = a["given"].split(/ |,/)
          if given.length > 1
            temp = []
            given.each do |g|
              temp << "#{g[0].capitalize}."
            end
            authors << temp.join(" ")
          else
            if a["given"].length == 2 and not a["given"].include? "."
              authors << "#{a["given"][0]}. #{a["given"][1]}."
            else
              authors << "#{a["given"][0].titleize}."
            end
          end
        end
      end
      authors = authors.join(", ")

      params[:resource][:author] = authors
      params[:resource][:year] = @doi["message"]["issued"]["date-parts"][0][0]
      params[:resource][:title] = @doi["message"]["title"][0]
      params[:resource][:journal] = @doi["message"]["container-title"][0]
      params[:resource][:volume_pages] = "#{@doi["message"]["volume"]}, #{@doi["message"]["page"]}"

    else
      # author_vec = []
      # authors = params[:resource][:author].split(",")
      # authors.each do |author|
      #   temp = author.strip.split(" ")
      #   author_vec << temp[0]
      #   i_vec = []
      #   temp[1].split("").each do |i|
      #     i_vec << "#{i}."
      #   end
      #   author_vec << i_vec.join(" ")
      # end
      # params[:resource][:author] = author_vec.join(", ")

    end




    if @resource.update(resource_params)
      redirect_to @resource, flash: {success: "Resource was successfully updated." }
    else
      render action: 'edit'
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end

  def expunge
    Observation.where("resource_id = ?", @resource.id).each do |obs|
      obs.destroy
    end

    redirect_to @resource, flash: {success: "Resource observations successfully expunged." }
  end

  def export
    if params[:checked]
      @observations = Observation.where(:resource_id => params[:checked])
      @observations = observation_filter(@observations)
    else
      @observations = []
    end
    
    send_zip(@observations, params[:taxonomy], params[:contextual], params[:global])                   
 end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:author, :year, :title, :resource_type, :doi_isbn, :journal, :volume_pages, :pdf_name, :resource_notes, :approval_status, :user_id)
    end

end
