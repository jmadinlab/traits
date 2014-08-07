class StaticPagesController < ApplicationController

  before_action :editor, only: [:meta]

  def home
    @mea = Measurement.all.size
    @obs = Observation.all.size
    
    @locations = Location.all
  end
  
  def help
  end

  def meta
    query = Trait.all
    query = query.status(params[:status]) if params[:status]
    @traits = query.all
  end

  def download
  end

  def about
  end

  def contact
  end
end
