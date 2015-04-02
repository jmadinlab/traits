class Specie < ActiveRecord::Base

  belongs_to :user
  has_many :observations
  has_paper_trail
  validates :specie_name, :presence => true

  has_many :synonyms, :dependent => :destroy
  accepts_nested_attributes_for :synonyms, :reject_if => :all_blank, :allow_destroy => true

  default_scope -> { order('specie_name ASC') }
  
  searchable do
    text :specie_name
    string :specie_name_sortable do 
      specie_name
    end
    text :synonyms do
      synonyms.map{ |synonym| synonym.synonym_name }
    end
  end
    
end
