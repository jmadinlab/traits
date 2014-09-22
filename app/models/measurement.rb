class Measurement < ActiveRecord::Base
  belongs_to :observation
  belongs_to :user
  belongs_to :trait
  belongs_to :standard
  belongs_to :methodology
  #belongs_to :traitvalue

  has_paper_trail
  
  # default_scope joins(:trait).order('traits.trait_class ASC, traits.trait_name ASC, created_at ASC').readonly(false)
  
  validates :trait, :presence => true
  validates :standard, :presence => true
  validates :value, :presence => true
  #validate :has_value
  #validates :traitvalue, :presence => true
  #validates :value_type, :presence => true
  # validates :orig_value, :presence => true

  #validate :check_duplicates, :on => [:create, :update]
  
  private
  def check_duplicates
    puts 'checking duplication'
    puts self.observation
    observations = Observation.where( :coral_id => self.observation.coral_id,
                                      :resource_id => self.observation.resource_id).joins(:measurements).where('measurements.trait_id IS ? AND
                                                                                        measurements.standard_id IS ? AND measurements.value IS ?', self.trait_id, self.standard_id, self.value)
    
    if observations.count > 0
      puts "there is a duplicate value"
      observations.each do |obs|
        errors.add(:observation, "Duplicate Value Exists. Check Observation : " + obs.id.to_s)

      end
      false
    end

    true
  end

end
