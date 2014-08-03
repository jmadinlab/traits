class Resource < ActiveRecord::Base

  has_many :citations#, :dependent => true
  has_many :traits, :through => :citations
  belongs_to :user
  has_paper_trail
  
  validates :author, :presence => true
  validates :title, :presence => true
  # validates :user_id, :presence => true

  searchable do
    text :author
    text :title
    text :year
    text :journal
  end

  '''
  def self.search(search)
      if search
        where("id LIKE ? OR author LIKE ? OR title LIKE ? OR year LIKE ? OR journal LIKE ?", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%")
      else
        all
      end
  end  
'''
  
end
