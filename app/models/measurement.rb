class Measurement < ActiveRecord::Base
  belongs_to :observation
  belongs_to :user
  belongs_to :trait
  belongs_to :standard
  belongs_to :methodology

  has_paper_trail
  
  # default_scope joins(:trait).order('traits.trait_class ASC, traits.trait_name ASC, created_at ASC').readonly(false)
  
  validates :trait, :presence => true
  validates :standard, :presence => true
  validates :value, :presence => true
  #validates :value_type, :presence => true
  # validates :orig_value, :presence => true

  
end
