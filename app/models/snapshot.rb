class Snapshot < ActiveRecord::Base
  belongs_to :user

  validates :snapshot_date, presence: true
  validates :snapshot_notes, presence: true

  validates_uniqueness_of :snapshot_date#, conditions: { -> { where("DATE(created_at) = ?", Date.today) } }


  default_scope -> { order('snapshot_date DESC') }

  searchable do
    text :snapshot_notes  
  end

end
