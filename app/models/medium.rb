class Medium < ApplicationRecord
  has_many :claims
  has_many :srcs
  has_many :medium_reviews
  belongs_to :user

  validates :name, presence: true
  validates :sharing_mode, presence: true

end
