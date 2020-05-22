class Src < ApplicationRecord
  has_many :claims
  has_many :src_reviews
  belongs_to :user
  belongs_to :medium, required: false

  validates :name, presence: true
  validates :sharing_mode, presence: true
  
end
