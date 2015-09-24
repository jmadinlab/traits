class User < ActiveRecord::Base

  has_many :observations
  has_many :species
  has_many :traits
  has_many :resources
  has_many :methodologies
  has_many :locations
  has_many :standards
  has_many :issues
  
  has_paper_trail :ignore => [:last_seen_at, :remember_token]

  default_scope -> { order('name ASC') }
  
  before_save { self.email = email.downcase }
  before_create :create_remember_token
  validates :name, presence: true, length: { maximum: 50 }
  # validates :last_name, presence: true, length: { maximum: 50 }
  # validates :institution, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 6 }, :on => [:create, :update], if: "password_confirmation"

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end
  
  def send_password_reset
    self.password_reset_token = User.new_remember_token
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  private

    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
end
