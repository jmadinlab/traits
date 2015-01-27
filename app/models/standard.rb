class Standard < ActiveRecord::Base

  belongs_to :user
  has_many :measurements
  has_many :traits
  has_paper_trail
  
  validates :standard_name, :presence => true
  validates :standard_class, :presence => true
  
  searchable do
    text :standard_name  
    text :standard_unit 
    text :standard_class 
    string :standard_class_sortable do 
      standard_class
    end
  end
  
  '''
  def self.search(search)
      if search
        where("standard_name LIKE ? OR standard_class LIKE ? OR standard_unit LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%")
      else
        all
      end
  end  
  '''
end
