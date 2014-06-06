class Trait < ActiveRecord::Base
  belongs_to :standard
  belongs_to :user
  has_paper_trail
  
  has_many :measurements, :dependent => :destroy
  validates :trait_name, :presence => true

  has_many :citations#, :dependent => true
  has_many :resources, :through => :citations

  def self.search(search)
      if search
        where('trait_name LIKE ? OR trait_class LIKE ?', "%#{search}%", "%#{search}%")
      else
        all
      end
  end  

end
