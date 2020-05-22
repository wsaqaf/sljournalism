class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :claim
#  belongs_to :medium
#  belongs_to :src
#  belongs_to :resource
end
