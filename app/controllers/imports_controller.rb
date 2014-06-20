
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
				
		puts "model_name from controller"
		puts @model_name

		
		
		@product_import = Import.new(params[:import])
		
		@product_import.set_model_name(@model_name)
		

		if @product_import.save
			redirect_to root_url, notice: "Imported successfully"
		else
			render :new
			#redirect_to request.referer , :@product_import => @product_import

		end
		
	end

	private

    def import_params
      params.require(:import).permit(:file)
    end


end