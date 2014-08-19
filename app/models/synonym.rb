class Synonym < ActiveRecord::Base
  belongs_to :coral
  validates :synonym_name, :presence => true
end
