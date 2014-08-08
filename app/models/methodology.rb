class Methodology < ActiveRecord::Base
	has_and_belongs_to_many :traits, :dependent => :destroy
	has_many :measurements
	accepts_nested_attributes_for :traits, :reject_if => :all_blank, :allow_destroy => true
  
  searchable do
    text :methodology_name  
  end

  '''
	def self.search(search)
      if search
        where("methodology_name LIKE ?", "%#{search}%")
      else
        all
      end
  end  

  '''
end
