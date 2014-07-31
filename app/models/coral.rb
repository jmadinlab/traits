class Coral < ActiveRecord::Base
  has_many :observations
  has_paper_trail
  validates :coral_name, :presence => true

  has_many :synonyms, :dependent => :destroy
  accepts_nested_attributes_for :synonyms, :reject_if => :all_blank, :allow_destroy => true

  def self.search(search)
      if search
        where('coral_name LIKE ?', "%#{search}%")
      else
        all
      end
  end  

end
