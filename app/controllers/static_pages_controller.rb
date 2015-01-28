class StaticPagesController < ApplicationController

  before_action :editor, only: [:meta, :show, :duplicate, :uploads]

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

  def uploads
  end

  def duplicate
    @trait = Trait.find(params[:id])
  end

  def about
  end

  def procedures
  end

  def editors
  end

  def contact
  end

  def export_location_trait
    
    traits = Trait.where("release_status IS ? OR release_status IS ?", "ready_for_release", "needs_work_before_release")
    # traits = Trait.where("trait_class IS NOT ?", "Contextual")
    locations = Location.all

    csv_string = CSV.generate do |csv|

      csv << ["location_name", "lat", "lon", "measurements"]
      temp = 0
      locations.each do |loc|
        temp = 0
        traits.sort_by{|t| t[:trait_name]}.each do |tra|

          temp = temp + Measurement.where("trait_id IS ?", tra.id).joins(:observation).where("location_id IS ?", loc.id).size
        end

        csv << [loc.location_name, loc.latitude, loc.longitude, temp]

      end
    end

    send_data csv_string, 
     :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
     :disposition => "attachment; filename=location_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end

  def export_coral_trait
    
    if signed_in? && current_user.editor?
      measurements = Measurement.joins(:trait).where("release_status IS ?", "ready_for_release")
    end
    
    traits = Trait.where("release_status IS ? OR release_status IS ?", "ready_for_release", "needs_work_before_release")
    # traits = Trait.where("trait_class IS NOT ?", "Contextual")
    corals = Specie.all

    csv_string = CSV.generate do |csv|

      # csv << ["measurement_id", "trait_id", "measurements"]

      # observations.each do |obs|
      head = ["coral_name"]
      temp = 0
      corals.sort_by{|c| c[:coral_name]}.each do |cor|
        keep = [cor.coral_name]
        traits.sort_by{|t| t[:trait_name]}.each do |tra|
          if temp == 0
            head << tra.trait_name
          end

          keep << Measurement.where("trait_id IS ?", tra.id).joins(:observation).where("coral_id IS ?", cor.id).size
        end
        if temp == 0
          csv << head
        end
        temp = 1

        csv << keep
        # temp << [tra.trait_name, cor.coral_name, measurements.size]
      end
    end

    send_data csv_string, 
     :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
     :disposition => "attachment; filename=trait_coral_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end

  def export_trait
        
    traits = Trait.where("release_status IS ? OR release_status IS ?", "ready_for_release", "needs_work_before_release")

    csv_string = CSV.generate do |csv|

      csv << ["trait_name", "measurements"]

      traits.sort_by{|t| t[:trait_name]}.each do |tra|
        csv << [tra.trait_name, Measurement.where("trait_id IS ?", tra.id).size]
      end

    end

    send_data csv_string, 
     :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
     :disposition => "attachment; filename=trait_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end

end
