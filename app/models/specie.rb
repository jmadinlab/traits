class Specie < ActiveRecord::Base
  has_many :observations
  has_paper_trail
  validates :specie_name, :presence => true

  has_many :synonyms, :dependent => :destroy
  accepts_nested_attributes_for :synonyms, :reject_if => :all_blank, :allow_destroy => true

  default_scope -> { order('specie_name ASC') }
  
  searchable do
    text :specie_name
    text :synonyms do
      synonyms.map{ |synonym| synonym.synonym_name }
    end
  end
  
  
  '''
  def self.search(search)
      if search
        (where("specie_name LIKE ?", "%#{search}%") +
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