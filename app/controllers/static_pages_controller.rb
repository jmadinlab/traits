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
    # params[:editor] = "ready_for_release" if params[:status].blank?
    query = Trait.all
    query = query.editor(params[:editor]) if not params[:editor].blank?
    @traits = query.all
  end

  def show
    @trait = Trait.find(params[:id])
  end

  def duplicate
    @trait = Trait.find(params[:id])
  end

  def about
  end

  def contact
  end
end
