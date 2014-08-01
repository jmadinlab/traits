class Coral < ActiveRecord::Base
  has_many :observations
  has_paper_trail
  validates :coral_name, :presence => true

  has_many :synonyms, :dependent => :destroy
  accepts_nested_attributes_for :synonyms, :reject_if => :all_blank, :allow_destroy => true

  default_scope -> { order('coral_name ASC') }
  
  searchable do
    text :coral_name  
  end
  
  '''
  def self.search(search)
      if search
        (where("coral_name LIKE ?", "%#{search}%") +
        joins(:synonyms).where("synonyms.synonym_name LIKE ?", "%#{search}%")).uniq
      else
        all
      end
  end  
  '''
end


    #   joins(:owner).where('dogs.name LIKE ? or owners.name LIKE ?', "%#{search}%", "%#{search}%")
    # else
    #   find(:all)
# @projects = Project. :joins => :categories, :conditions => ['projects.name LIKE ? OR categories.name LIKE ?', "%#{params[:search]}%", "%#{params[:search]}%"], :order => 'projects.id DESC'