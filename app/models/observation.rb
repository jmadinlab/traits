class Observation < ActiveRecord::Base
  belongs_to :user
  belongs_to :location
  belongs_to :specie
  belongs_to :resource
  has_paper_trail
  
  default_scope -> { order('specie_id ASC') }
  # default_scope :include => :species, :order => "species.specie_name ASC"
  # default_scope joins(:specie).order('species.specie_name ASC, created_at ASC').readonly(false)

  validates :user, presence: true
  validates :location, :presence => true
  validates :specie, :presence => true
  validates :measurements, :presence => true
  #validates :resource, :presence => true
    
  has_many :measurements, :dependent => :destroy, :before_add => :set_nest

  accepts_nested_attributes_for :measurements, :reject_if => :all_blank, :allow_destroy => true
  
  has_many :issues, :dependent => :destroy

  searchable do
    text :measurements do
      measurements.map{ |measurement| measurement.value }
    end
  end
  

  def set_nest(item)
    item.observation ||= self
  end
  
  '''
  def self.search(search)
      if search
        joins(:measurements).where("value LIKE ? OR orig_value LIKE ?", "%#{search}%", "%#{search}%")
      else
        all
      end
  end  

  '''


  
  
end
