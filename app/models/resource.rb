class Resource < ActiveRecord::Base

  has_many :citations#, :dependent => true
  has_many :traits, :through => :citations
  belongs_to :user
  has_paper_trail
  
  validates :author, :presence => true
  validates :title, :presence => true

  default_scope -> { order('author ASC') }

  searchable do
    text :author
    string :author_sortable do 
      author
    end
    text :title
    text :year
    text :journal
  end

end
