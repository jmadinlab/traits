class StaticPagesController < ApplicationController

  before_action :editor, only: [:meta, :show, :about, :help]

  def home
    @mea = Measurement.all.size
    @obs = Observation.all.size
    
    @locations = Location.all
  end
  
  def help
  end

  def meta
    # params[:status] = "ready_for_release" if params[:status].blank?
    query = Trait.all
    query = query.status(params[:status]) if params[:status]
    @traits = query.all
  end

  def show
    @trait = Trait.find(params[:id])
  end

  def about
  end

  def contact
  end
end
