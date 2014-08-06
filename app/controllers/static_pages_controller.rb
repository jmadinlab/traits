class StaticPagesController < ApplicationController

  before_action :contributor, only: [:meta]

  def home
    @mea = Measurement.all.size
    @obs = Observation.all.size
    
    @locations = Location.all
  end
  
  def help
  end

  def meta
    @traits = Trait.all
  end

  def about
  end

  def contact
  end
end
