class Location < ActiveRecord::Base
  
  belongs_to :user
  has_many :observations
  has_paper_trail
  
  validates :location_name, :presence => true
  validates :latitude, :presence => true
  validates :longitude, :presence => true

  default_scope -> { order('location_name ASC') }

  searchable do
    text :location_name  
    string :location_name_sortable do 
      location_name
    end
  end
  
  #def self.search(search)
  #    if search
  #      where('location_name LIKE ?', "%#{search}%")
  #    else
  #      all
  #    end
  #end  

end
