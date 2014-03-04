class Trait < ActiveRecord::Base
  belongs_to :standard
  belongs_to :user

  has_many :measurements, :dependent => :destroy
  validates :trait_name, :presence => true

  has_many :citations#, :dependent => true
  has_many :resources, :through => :citations

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
        where('trait_name LIKE ? OR trait_class LIKE ?', "%#{search}%", "%#{search}%")
      else
        all
      end
  end  

end
