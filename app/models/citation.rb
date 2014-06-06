class Citation < ActiveRecord::Base
  belongs_to :trait
  belongs_to :resource
  belongs_to :user
  has_paper_trail
  
  validates :trait, :presence => true#, :uniqueness => {:scope => :resource_id}
  validates :resource, :presence => true#, :uniqueness => {:scope => :trait_id}

  
end
