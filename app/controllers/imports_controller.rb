
class ImportsController < ApplicationController
	

	def new
		@product_import ||= Import.new
		@model_name = request.original_url.split("/").last.singularize.capitalize
		
		begin
			@model = @model_name.classify.constantize
		rescue
			redirect_to root_path, flash: {danger:  "Corresponding Model Name could not be retrieved" }
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
		
		# Save the actual file in the server
		uploaded_io = params[:import][:file]
		puts "uploaded file info"
		puts uploaded_io
	  File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
	    file.write(uploaded_io.read)
	  end
		

		render :new, notice: "Your request has been sent to the administrator"
	  '''
		
		if @product_import.save
			redirect_to root_url, notice: "Imported successfully"
		else
			render :new
			#redirect_to request.referer , :@product_import => @product_import

		end
		'''
	end
	
	def approve
		f = File.open(Rails.root.join(params[:file]), 'r')
		begin
			@model_name = params[:model].classify.constantize
		rescue
			redirect_to root_path, notice: "Corresponding Model Name could not be retrieved"
		end
		
		@product_import = Import.new(:file => f)

		@product_import.set_model_name(@model_name)

		puts "paramessss"
		puts  
		
		if @product_import.save
			redirect_to imports_path, notice: "Imported successfully"
		else
			puts "ERROR"
			render 'approve.html.erb'
			#redirect_to request.referer , :@product_import => @product_import

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


end