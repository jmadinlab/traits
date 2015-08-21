class Observation < ActiveRecord::Base
  belongs_to :user
  belongs_to :location
  belongs_to :specie
  belongs_to :resource
  has_paper_trail
  
  # default_scope -> { 
  #   joins(:specie).order('species.specie_name ASC') 
  # }

  default_scope -> { 
    joins(:specie).order('species.specie_name ASC') 
  }
  
  # default_scope -> {
  #   :joins => :specie, :order => 'species.specie_name DESC', :group => 'id'
  # }

  scope :remove_hidden, -> { 
    where.not(id: joins(measurements: :trait).where('traits.hide is true')) 
  }


  validates :user, presence: true
  validates :location, :presence => true
  validates :specie, :presence => true
  validates :measurements, :presence => true
  #validates :resource, :presence => true
    
  has_many :measurements, :dependent => :destroy, :before_add => :set_nest

  accepts_nested_attributes_for :measurements, :reject_if => :all_blank, :allow_destroy => true
  
  has_many :issues, :dependent => :destroy

  searchable do
    boolean :private  
    integer :user_id  
    text :measurements do
      measurements.map{ |measurement| measurement.value }
    end
  end
  

  def set_nest(item)
    item.observation ||= self
  end
  
end
