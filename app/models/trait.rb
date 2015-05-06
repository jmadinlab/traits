class Trait < ActiveRecord::Base
  belongs_to :standard
  belongs_to :user
  has_paper_trail
  
  has_many :measurements, :dependent => :destroy
  validates :trait_name, :presence => true
  validates :trait_name, :uniqueness => true
  validates :standard_id, :presence => true
  
  has_many :traitvalues, :dependent => :destroy

  # has_and_belongs_to_many :methodologies, :dependent => :destroy
  # accepts_nested_attributes_for :methodologies, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :traitvalues, :reject_if => :all_blank, :allow_destroy => true
  
  default_scope -> { order('trait_class ASC') }

  scope :editor, lambda {|ed| where("user_id = ?", ed)}

  searchable do
    text :trait_name
    text :trait_class
    boolean :hide
    string :trait_class_sortable do 
      trait_class
    end
  end

  '''
  def self.search(search)
    if search
      where("trait_name LIKE ? OR trait_class LIKE ?", "%#{search}%", "%#{search}%")
    else
      all
    end
  end  
  '''
end
