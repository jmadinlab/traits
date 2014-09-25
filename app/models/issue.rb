class Issue < ActiveRecord::Base
  belongs_to :user
  belongs_to :observation
  validates :issue_description, :presence => true

  default_scope -> { order('resolved ASC') }
end
