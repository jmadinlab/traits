class Traitvalue < ActiveRecord::Base
	belongs_to :trait
  #accepts_nested_attributes_for :traits, :reject_if => :all_blank, :allow_destroy => true

	def self.search(search)
      if search
        where('value_name LIKE ?', "%#{search}%")
      else
        all
      end
  end  
end
