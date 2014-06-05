class Standard < ActiveRecord::Base

  belongs_to :user
  has_many :measurements
  has_many :traits
  has_paper_trail
  
  validates :standard_name, :presence => true
  validates :standard_class, :presence => true

  def self.search(search)
      if search
        where('standard_name LIKE ? OR standard_class LIKE ? OR standard_unit LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
      else
        all
      end
  end  

end
