class Claim < ApplicationRecord

####
  has_many :taggings
  has_many :tags, through: :taggings

  def self.tagged_with(claim_name)
    Tag.find_by!(claim_name: claim_name).claims
  end

  def self.tag_counts
    Tag.select('tags.*, count(taggings.tag_id) as count').joins(:taggings).group('taggings.tag_id')
  end

  def tag_list
    tags.map(&:claim_name).join(', ')
  end

  def tag_list=(tag_list)
    self.tags = tag_list.split(',').map do |n|
      Tag.where(claim_name: n.strip).first_or_create!
    end
  end
####
#  acts_as_taggable
#  acts_as_taggable_on :tag_list

  belongs_to :user
  belongs_to :src, required: false
  belongs_to :medium, required: false
  has_many :claim_reviews


  validates :title, presence: true
  validates :has_image, presence: true
  validates :has_video, presence: true
  validates :has_text, presence: true

#  validates :reward_amount, :numericality => { :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1000000 }

  def medium_name
      medium.try(:name)
  end

  def medium_name=(name)
    self.medium = Medium.create_with(user_id: User.current_user.id).find_or_create_by(name: name) if name.present?
    begin
      self.medium.update(sharing_mode: 1)
    rescue
    end
  end

  def src_name
    src.try(:name)
  end

  def src_name=(name)
    self.src = Src.create_with(user_id: User.current_user.id).find_or_create_by(name: name) if name.present?
    begin
      self.src.update(sharing_mode: 1)
    rescue
    end
  end

  def self.language_options
    {"Svenska" => "sv", "English" => "en"}
  end

end
