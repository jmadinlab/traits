class ImportsController < ApplicationController
	before_action :contributor
	before_action :signed_in_user

	def new
		@item_import ||= Import.new
		# Get the model name from URL : /imports/observations => Observation
		@model_name = request.original_url.split("/").last.singularize.capitalize
		@model = get_model_name(@model_name)
	end


	def create
		@model_name = get_model_name(params[:import]['model_name'])
		@item_import = Import.new(params[:import])
		@item_import.set_model_name(@model_name)
	
		
		

		if @item_import.save
			# Todo : Change the user to the one responsible for that particular coral/trait/observation
			#UploadApprovalMailer.approve_all(@item_import.get_email_list).deliver

			# Save the actual file in the server
			uploaded_io = params[:import][:file]
			puts 'uploaded file info'
			puts uploaded_io.original_filename
			
			file_name, extension = uploaded_io.original_filename.split(".")
			file_name = [file_name, current_user.id, Date.today.strftime('%Y%m%d')].join('_')
			file_with_extension = [file_name, extension].join('.')

		  File.open(Rails.root.join('public', 'uploads', file_with_extension), 'wb') do |file|
		    file.write(uploaded_io.read)
		  end
		
			# render :new, notice: 'Your request has been sent to the administrator'
			
			redirect_to request.referer, flash: {success: "Imported successfully" } 
		else
			render :new
			#redirect_to request.referer , :@item_import => @item_import
		end
	end
	
	def approve
		if not current_user.admin?
			@corals = Coral.where(:approval_status => "pending", :user_id => current_user.id )
			@locations = Location.where(:approval_status => "pending", :user_id => current_user.id)
			@traits = Trait.where(:approval_status => "pending", :user_id => current_user.id)
			@standards = Standard.where(:approval_status => "pending", :user_id => current_user.id)
			@resources = Resource.where(:approval_status => "pending", :user_id => current_user.id)
			@observations = Observation.includes(:measurements).where("measurements.approval_status" => "pending")
		else
			@corals = Coral.where(:approval_status => "pending")
			@locations = Location.where(:approval_status => "pending")
			@traits = Trait.where(:approval_status => "pending")
			@standards = Standard.where(:approval_status => "pending")
			@resources = Resource.where(:approval_status => "pending")
			""" To do  : Show only the observation with measurements which contain traits that a user is editor of """
			@observations = Observation.includes(:measurements).where("measurements.approval_status" => "pending")
		end


		#@measurements = Measurement.where(:approval_status => "pending")
		reject = params[:reject]
		reject ? message = "Item/s Rejected!!!" : message = "Item/s approved!!!"
		
		if params[:checked]
			item_ids = params[:checked]
			i = 0
			item_ids.each do |item_id|
				@model_name = get_model_name(params[:item_type][i])
				
				find_and_approve_item(@model_name, item_id,reject)

				i = i + 1
			end
			redirect_to approve_path, flash: {success: message } 
		elsif params[:item_id]
			@model_name = get_model_name(params[:model])
			find_and_approve_item(@model_name, params[:item_id], reject)
			redirect_to approve_path, flash: {success: message } 

		else
			@item_import = Import.new
			render 'approve.html.erb'
		end
	end

	def show
		@files = Dir.glob("../public/uploads/**")
		@item_import = Import.new

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

    def find_and_approve_item(model_name, item_id, reject)
    	@item = model_name.find_by_id(item_id)
    	if not reject
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
			else
				@item.destroy!
			end
    end
end