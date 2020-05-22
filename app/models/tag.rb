class Tag < ApplicationRecord
  has_many :taggings
  has_many :claims, through: :taggings
#  has_many :media, through: :taggings
#  has_many :srcs, through: :taggings
#  has_many :resources, through: :taggings
end
