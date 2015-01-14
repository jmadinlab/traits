class Synonym < ActiveRecord::Base
  belongs_to :specie
  validates :synonym_name, :presence => true
end
