class Resource < ActiveRecord::Base

  has_many :citations#, :dependent => true
  has_many :traits, :through => :citations
  belongs_to :user

  validates :author, :presence => true
  validates :title, :presence => true
  # validates :user_id, :presence => true

  def self.search(search)
      if search
        where('id LIKE ? OR author LIKE ? OR title LIKE ? OR year LIKE ? OR journal LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%")
      else
        all
      end
  end  

  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end

end
