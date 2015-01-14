class SearchController < ApplicationController
	def index
		
		if params[:search] && params[:search] != ""
			if not params[:model_name]
				params[:model_name] = ['Location', 'Specie', 'Trait', 'Resource', 'Standard', 'Observation']
			end
			@result_present = false
			params[:model_name].each do |m|
				@model = m.classify.constantize
				name = m.downcase + '_search'
				puts "name: "
				puts name
				
				search_result = @model.search do
					fulltext params[:search]
					paginate :page => 1, :per_page => 100
				end

				if not search_result.results.blank?
					@result_present = true
				end
				
				instance_variable_set("@#{name}", search_result)
			end
		else
			@location_search = nil
		end
	end

	def json_completion
		model_names = ['Location', 'Specie', 'Trait', 'Standard']
		
		
		bucket = []
		model_names.each do |m|
				@model = m.classify.constantize
				name = m.downcase + '_search'
				puts "name: "
				puts name
				
				search = @model.search do
					keywords(params["search"])
				end

				if search.results.count > 0
					bucket << '<<<<< ' + m + ' >>>>>'
					column_name = @model.column_names[1]
					bucket << search.results.map{ |x| x.attributes[column_name]}
				end
		end

		render :json => bucket.flatten
	end
end
