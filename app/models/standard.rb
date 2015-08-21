class Standard < ActiveRecord::Base

  belongs_to :user
  has_many :measurements
  has_many :traits
  has_paper_trail
  
  validates :standard_name, :presence => true
  validates :standard_class, :presence => true

  default_scope -> { order('standard_name ASC') }
  
  searchable do
    text :standard_name  
    text :standard_unit 
    text :standard_class 
    string :standard_name_sortable do 
      standard_name
    end
    string :standard_class_sortable do 
      standard_class
    end
  end

end
