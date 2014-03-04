class StaticPagesController < ApplicationController

  def home
    @mea = Measurement.all.size
    @obs = Observation.all.size
    
    @locations = Location.all
  end
  
  def help
  end

  def about
  end

  def contact
  end
end
