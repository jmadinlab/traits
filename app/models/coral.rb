class Coral < ActiveRecord::Base
  has_many :observations
  has_paper_trail
  validates :coral_name, :presence => true

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
        where('coral_name LIKE ?', "%#{search}%")
      else
        all
      end
  end  

end
