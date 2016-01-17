class StaticPagesController < ApplicationController

  before_action :editor, only: [:release, :meta, :show, :duplicate, :uploads]

  def home
    @mea = Measurement.all.size
    @obs = Observation.all.size
    
    @locations = Location.all
  end
  
  def test
    require 'savon'

    client = Savon.client(
        :wsdl => "http://www.marinespecies.org/aphia.php?p=soap&wsdl=1",
        :open_timeout => 10,
        :read_timeout => 10,
        :log => false
    )

    @test = client.call(:get_aphia_id, message: { scientificname: "Acropora hyacinthus" })

  end

  def meta
    # params[:editor] = "ready_for_release" if params[:status].blank?
    query = Trait.all
    query = query.editor(params[:editor]) if not params[:editor].blank?
    query = query.where(:release_status => params[:release_status]) if not params[:release_status].blank?
    @traits = query.all
  end

  def release

    @traits = Trait.where(:release_status => "ready_for_release")
    @observations = Observation.where("private IS false AND id IN (?)", Measurement.where("trait_id IN (?)", @traits.map(&:id)).map(&:observation_id))

  end

  def uploads
  end

  def duplicate
    @trait = Trait.find(params[:id])
  end

  def procedures
  end

  def editors
  end

  def contact
  end

  def export_location_trait
    
    # traits = Trait.where("release_status IS ? OR release_status IS ?", "ready_for_release", "needs_work_before_release")
    traits = Trait.where("trait_class != ?", "Contextual")
    locations = Location.all

    csv_string = CSV.generate do |csv|

      csv << ["location_name", "lat", "lon", "measurements"]
      temp = 0
      locations.each do |loc|
        temp = 0
        traits.sort_by{|t| t[:trait_name]}.each do |tra|

          temp = temp + Measurement.where("trait_id = ?", tra.id).joins(:observation).where("location_id = ?", loc.id).size
        end

        csv << [loc.location_name, loc.latitude, loc.longitude, temp]

      end
    end

    send_data csv_string, 
     :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
     :disposition => "attachment; filename=location_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end

  def export_specie_trait
        
    # traits = Trait.where("release_status = ?", "ready_for_release")
    traits = Trait.where("hide IS NOT true AND trait_class != ? AND trait_class != ?", "Contextual", "")
    species = Specie.all

    csv_string = CSV.generate do |csv|

      head = ["specie_name", "zooxanthellate"]
      real = ["release", ""]
      clas = ["class", ""]
      temp = 0
      species.sort_by{|c| c[:specie_name]}.each do |cor|
        keep = [cor.specie_name]
        zoox = Measurement.where("trait_id = ?", 41).joins(:observation).where("specie_id = ?", cor.id)
        if zoox.present?
          keep << zoox.first.value
        else
          keep << ""
        end
        traits.sort_by{|t| t[:trait_name]}.each do |tra|
          if temp == 0
            head << tra.trait_name
            if tra.release_status == "ready_for_release"
              real << 1
            else
              real << 0
            end
            if tra.trait_class.present?
              clas << tra.trait_class
            else
              clas << ""
            end
          end
          keep << Measurement.where("trait_id = ?", tra.id).joins(:observation).where("specie_id = ?", cor.id).size
        end
        if temp == 0
          csv << head
          csv << clas
          csv << real
        end
        temp = 1
        csv << keep
      end
    end

    send_data csv_string, 
     :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
     :disposition => "attachment; filename=trait_coral_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end

  def export_ready_trait
    
    traits = Trait.where("release_status = ?", "ready_for_release")

    csv_string = CSV.generate do |csv|

      csv << ["trait_name", "class", "description", "standard", "unit", "values", "value description", "measurements", "references"]
      traits.sort_by{|t| t[:trait_name]}.each do |tra|

        csv << [
          tra.trait_name, 
          tra.trait_class, 
          tra.trait_description, 
          tra.standard.standard_name, 
          tra.standard.standard_unit, 
          tra.traitvalues.collect(&:value_name).join(", "), 
          tra.traitvalues.map(&:value_description).join(", "), 
          tra.measurements.size, 
          [Observation.where(:id => tra.measurements.map(&:observation_id)).map(&:resource_id).uniq.join(", "), 
          Observation.where(:id => tra.measurements.map(&:observation_id)).map(&:resource_secondary_id).uniq.reject(&:blank?).join(", ")].join(", ")#, 
          # "https://coraltraits.org/traits/#{tra.id}.zip"
        ]
      end
    end

    send_data csv_string, 
     :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
     :disposition => "attachment; filename=ready_trait_#{Date.today.strftime('%Y%m%d')}.csv"
          
  end

  def export_release_resources
    ids = Observation.joins(:measurements).where(:measurements => {:trait_id => Trait.where(:release_status => 'ready_for_release')}).map{|f| [f.resource_id, f.resource_secondary_id]}.uniq.compact
    resources = Resource.where(:id => ids)

    header = ["id", "author", "year", "title", "doi_isbn", "journal", "volume_pages"]
    csv_string = CSV.generate do |csv|
      csv << ["resource_id", "author", "year", "title", "doi_isbn", "journal", "volume_pages"]
      resources.each do |obs|
        csv << obs.attributes.values_at(*header)
      end
    end
    send_data csv_string, 
     :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
     :disposition => "attachment; filename=export_release_resources_#{Date.today.strftime('%Y%m%d')}.csv"   
  end

  def export_release
    ids = Observation.joins(:measurements).where(:measurements => {:trait_id => Trait.where(:release_status => 'ready_for_release')}).map(&:id).join(',')
    observations = Observation.find_by_sql("SELECT mea.observation_id, CASE WHEN obs.private='f' THEN 1 ELSE 0 END AS access, obs.user_id, obs.specie_id, spe.specie_name, obs.location_id, loc.location_name, CASE WHEN loc.latitude=0 THEN NULL ELSE loc.latitude END AS latitude, CASE WHEN loc.longitude=0 THEN NULL ELSE loc.longitude END AS longitude, obs.resource_id, obs.resource_secondary_id, mea.id, mea.trait_id, tra.trait_name, tra.trait_class, mea.standard_id, sta.standard_unit, mea.methodology_id, meth.methodology_name, mea.value, mea.value_type, mea.precision, mea.precision_type, mea.precision_upper, mea.replicates, mea.notes
      FROM observations AS obs
        right OUTER JOIN species AS spe
            ON spe.id = obs.specie_id
        left OUTER JOIN locations AS loc
            ON loc.id = obs.location_id
        right OUTER JOIN measurements AS mea
            ON mea.observation_id = obs.id
        right OUTER JOIN traits AS tra
            ON mea.trait_id = tra.id
        right OUTER JOIN standards AS sta
            ON mea.standard_id = sta.id
        left OUTER JOIN methodologies AS meth
            ON mea.methodology_id = meth.id
      WHERE obs.private='f' AND obs.id IN (#{ids})
      ORDER BY obs.id;")
    header = ["observation_id", "access", "user_id", "specie_id", "specie_name", "location_id", "location_name", "latitude", "longitude", "resource_id", "resource_secondary_id", "measurement_id", "trait_id", "trait_name", "trait_class", "standard_id", "standard_unit", "methodology_id", "methodology_name", "value", "value_type", "precision", "precision_type", "precision_upper", "replicates", "notes"]

    csv_string = CSV.generate do |csv|
      csv << header
      observations.each do |obs|
        csv << obs.attributes.values_at(*header)
      end
    end

    send_data csv_string.html_safe, 
     :type => 'text/csv; charset=iso-8859-1; header=present', :stream => true,
     :disposition => "attachment; filename=export_release_#{Date.today.strftime('%Y%m%d')}.csv"              
  end

end
