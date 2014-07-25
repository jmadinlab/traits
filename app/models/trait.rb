class Trait < ActiveRecord::Base
  belongs_to :standard
  belongs_to :user
  has_paper_trail
  
  has_many :measurements, :dependent => :destroy
  validates :trait_name, :presence => true

  has_many :citations#, :dependent => true
  has_many :resources, :through => :citations
  
  has_many :traitvalues, :dependent => :destroy

  has_and_belongs_to_many :methodologies, :dependent => :destroy
  accepts_nested_attributes_for :methodologies, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :traitvalues, :reject_if => :all_blank, :allow_destroy => true

  def self.search(search)
    if search
      where('trait_name LIKE ? OR trait_class LIKE ?', "%#{search}%", "%#{search}%")
    else
      all
    end
  end  
end
