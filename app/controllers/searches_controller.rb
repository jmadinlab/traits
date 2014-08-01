class SearchesController < ApplicationController
	def index
		if params[:search]
			params[:model_name].each do |m|
				@model = m.classify.constantize
				name = m.downcase + '_search'
				puts "name: "
				puts name
				
				search_result = @model.search do
					fulltext params[:search]
				end
				instance_variable_set("@#{name}", search_result)
			end
		else
			@location_search = nil
		end
	end
end
