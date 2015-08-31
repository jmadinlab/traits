class Release < ActiveRecord::Base
  belongs_to :user

  validates :release_date, presence: true
  validates :release_notes, presence: true
  validates :release_code, presence: true
  validates :release_code, :uniqueness => true

  validates_uniqueness_of :release_code
  validates_format_of :release_code, with: /\A(?:(\d+)\.)?(?:(\d+)\.)?(\*|\d+)\z/i, on: [:create, :update]

  default_scope -> { order('release_code DESC') }

  searchable do
    text :release_notes  
  end


  # validate :release_code_check

  def release_code_check
    if self.release_code.present?

      newer_release = Semantic::Version.new self.release_code
      newer_date = self.release_date

      Release.all.each do |old|
        older_release = Semantic::Version.new old.release_code
        older_date = old.release_date

        if (older_release > newer_release and newer_date > older_date) 
          self.errors[:base] << "Release behind previous release."
        end
      end
    end
  end

end
