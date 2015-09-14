class Resource < ActiveRecord::Base

  belongs_to :user
  has_many :observations

  has_paper_trail
  
  # validates :author, :presence => true
  # validates :title, :presence => true
  validates_uniqueness_of :doi_isbn, :allow_blank => true
  validate :check_consistency

  # default_scope -> { order('author ASC') }

  VALID_DOI_REGEX = /\b(10[.][0-9]{4,}(?:[.][0-9]+)*\/(?:(?!["&\'<>])\S)+)\b/
  # VALID_DOI_REGEX = /(10.(\d)+\/(\S)+)/
  validates :doi_isbn, format: { with: VALID_DOI_REGEX }, :allow_blank => true

# $pattern = '';

  searchable do
    text :author

    string :author_sortable do 
      author
    end

    integer :count_sortable do
      observations.size
    end

    text :doi_isbn
    text :title
    text :year
    text :journal
  end

  private

  def check_consistency
    errors.add(:base, 'Enter either doi or author and title') if ((author.blank? | title.blank?) & doi_isbn.blank?)
  end

end
