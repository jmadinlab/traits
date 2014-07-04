class ImportsController < ApplicationController
	before_action :contributor
	before_action :signed_in_user

	def new
		@product_import ||= Import.new
		@model_name = request.original_url.split("/").last.singularize.capitalize
		
		begin
			@model = @model_name.classify.constantize
		rescue
			redirect_to imports_path, flash: {danger:  "Corresponding Model Name could not be retrieved" }
		end
	end


	def create
		begin
			@model_name = params[:import]["model_name"].classify.constantize
		rescue
			render :new, notice: "Corresponding Model Name could not be retrieved"
		end
		
		@product_import = Import.new(params[:import])
		
		@product_import.set_model_name(@model_name)
		
		"""
		# Save the actual file in the server
		uploaded_io = params[:import][:file]
		puts 'uploaded file info'
		puts uploaded_io
	  File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
	    file.write(uploaded_io.read)
	  end
		

		render :new, notice: 'Your request has been sent to the administrator'
		"""

		if @product_import.save
			# Todo : Change the user to the one responsible for that particular coral/trait/observation
			UploadApprovalMailer.approve(current_user).deliver
			redirect_to request.referer, flash: {success: "Imported successfully" } 
		else
			render :new
			#redirect_to request.referer , :@product_import => @product_import

		end
		
	end
	
	def approve

		puts 'current user id : '
		puts current_user.id

		@corals = Coral.where(:approval_status => "pending", :user_id => current_user.id)
		@locations = Location.where(:approval_status => "pending", :user_id => current_user.id)
		@traits = Trait.where(:approval_status => "pending", :user_id => current_user.id)
		@standards = Standard.where(:approval_status => "pending", :user_id => current_user.id)
		@resources = Resource.where(:approval_status => "pending", :user_id => current_user.id)
		@observations = Observation.includes(:measurements).where("measurements.approval_status" => "pending")

		#@measurements = Measurement.where(:approval_status => "pending")
		
		if params[:checked]
			item_ids = params[:checked]
			i = 0
			item_ids.each do |item_id|
				@model_name = get_model_name(params[:item_type][i])
				find_and_approve_item(@model_name, item_id)

				i = i + 1
			end
			redirect_to approve_path, flash: {success: "Items approved!!!" } 
		elsif params[:item_id]
			@model_name = get_model_name(params[:model])
			find_and_approve_item(@model_name, params[:item_id])
			redirect_to approve_path, flash: {success: "Item approved!!!" } 

		else
			@product_import = Import.new
			render 'approve.html.erb'
		end
	end

	def show
		@files = Dir.glob("../public/uploads/**")
		@product_import = Import.new

	end

	private

    def import_params
      params.require(:import).permit(:file)
    end

    def get_model_name(name)
			begin
				@model_name = name.classify.constantize
			rescue
				redirect_to imports_path, flash: {danger: "Corresponding Model Name could not be retrieved" }
			end

    end

    def find_and_approve_item(model_name, item_id)
    	@item = model_name.find_by_id(item_id)
			@item.approval_status = "approved"
			@item.save!
			
			puts "printing model name:"
			puts model_name
			if model_name.to_s == "Observation"
				puts "processing measurements"
				@item.measurements.each do |mea|
					mea.approval_status = "approved"
					mea.save!
				end
			end
		
    end


end