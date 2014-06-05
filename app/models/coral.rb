class Coral < ActiveRecord::Base
  has_many :observations
  has_paper_trail
  validates :coral_name, :presence => true

  def self.search(search)
      if search
        where('coral_name LIKE ?', "%#{search}%")
      else
        all
      end
  end  

end
