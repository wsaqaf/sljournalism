class User < ApplicationRecord

  has_many :claims, dependent: :destroy
  has_many :srcs, dependent: :destroy
  has_many :media, dependent: :destroy
  has_many :claim_reviews, dependent: :destroy
  has_many :medium_reviews, dependent: :destroy
  has_many :src_reviews, dependent: :destroy
  has_many :resources, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  acts_as_token_authenticatable

  validates :name, presence: true
  validates_format_of :email,:with => Devise::email_regexp

  validates :role, inclusion: %w(admin client factchecker user)

   def admin?
     self.role == 'admin'
   end

   def self.current_user
     Thread.current[:user]
   end

   def self.current_user=(user)
     Thread.current[:user] = user
   end

end
