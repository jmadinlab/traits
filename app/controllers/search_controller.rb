class SearchController < ApplicationController

	def index
		if params[:search] && params[:search] != ""
			if not params[:model_name]
				params[:model_name] = ['Specie', 'Trait', 'Location', 'Resource', 'Standard', 'Observation', 'Methodology']
			end

			@result_present = false
			@store = {}

			params[:model_name].each do |m|
				@model = m.classify.constantize
				name = m.downcase + '_search'
				puts "name: "
				puts name
				puts m

				search_result = @model.search do
					without(:hide, true) if m == "Trait"
					fulltext params[:search]

					paginate :page => 1, :per_page => 30
				end

				if not search_result.results.blank?
					@result_present = true
				end
				
				instance_variable_set("@#{name}", search_result)

				@store[m.downcase] = search_result.results.size
			end

			# Redirect if only 1 result in 1 model
			singletons = @store.select{|key, hash| hash == 1 }
			others = @store.select{|key, hash| hash > 1 }
			models = @store.select{|key, hash| hash > 0 }

			if singletons.count == 1 and others.count == 0
				puts singletons.keys
				redirect_to eval("#{singletons.keys[0]}_path(@#{singletons.keys[0]}_search.results.first, :search => params[:search])")
			elsif models.count == 1
				redirect_to eval("#{models.keys[0].pluralize}_path(:search => params[:search])")
			end

		else
			# @location_search = nil
		end
	end

	def json_completion
		model_names = ['Specie', 'Trait', 'Location', 'Resource', 'Standard', 'Methodology', 'Version']
		
		bucket = []
		model_names.each do |m|
				@model = m.classify.constantize
				name = m.downcase + '_search'
				puts "name: "
				puts name
				
				search = @model.search do
					without(:hide, true) if m == "Trait"
					fulltext params[:search]
					# keywords(params["search"])
				end

				if search.results.count > 0
					bucket << '------ ' + m.pluralize + ' ------'
					column_name = @model.column_names[1]
					bucket << search.results.map{ |x| x.attributes[column_name]}
				end
		end

		render :json => bucket.flatten
	end
end
