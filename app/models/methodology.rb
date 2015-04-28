class Methodology < ActiveRecord::Base

  belongs_to :user
	# has_and_belongs_to_many :traits, :dependent => :destroy
	has_many :measurements
	# accepts_nested_attributes_for :traits, :reject_if => :all_blank, :allow_destroy => true
  
  default_scope -> { order('methodology_name ASC') }

  searchable do
    text :methodology_name  
    string :methodology_name_sortable do 
      methodology_name
    end
  end

end
