class Observation < ActiveRecord::Base
  belongs_to :user
  belongs_to :location
  belongs_to :coral
  belongs_to :resource
  has_paper_trail
  
  default_scope -> { order('coral_id ASC') }
  # default_scope :include => :corals, :order => "corals.coral_name ASC"
  # default_scope joins(:coral).order('corals.coral_name ASC, created_at ASC').readonly(false)

  validates :user, presence: true
  validates :location, :presence => true
  validates :coral, :presence => true
  #validates :resource, :presence => true
    
  has_many :measurements, :dependent => :destroy
  accepts_nested_attributes_for :measurements, :reject_if => :all_blank, :allow_destroy => true
  
  def self.search(search)
      if search
        joins(:measurements).where("value LIKE ? OR orig_value LIKE ?", "%#{search}%", "%#{search}%")
      else
        all
      end
  end  
  
end
