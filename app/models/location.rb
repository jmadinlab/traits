class Location < ActiveRecord::Base
  
  belongs_to :user
  has_many :observations
  has_paper_trail
  
  validates :location_name, :presence => true
  validates :latitude, :presence => true
  validates :longitude, :presence => true

  # default_scope -> { order('latitude ASC') }

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end

  def self.search(search)
      if search
        where('location_name LIKE ?', "%#{search}%")
      else
        all
      end
  end  

end
