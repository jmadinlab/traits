class Citation < ActiveRecord::Base
  belongs_to :trait
  belongs_to :resource
  belongs_to :user
  has_paper_trail
  
  validates :trait, :presence => true#, :uniqueness => {:scope => :resource_id}
  validates :resource, :presence => true#, :uniqueness => {:scope => :trait_id}

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end

end
