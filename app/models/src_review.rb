class SrcReview < ApplicationRecord
  belongs_to :user
  belongs_to :src

  cattr_accessor :form_steps do
  ########Step Names#########
  %w(s1 s2 s3 s4 s5 s6 s7 s8 s9)
  ########Step Names#########
  end

  attr_accessor :form_step

  validates :src_review_verdict, presence: true, if: -> { required_for_step?(:s8) }
  validates :src_review_sharing_mode, presence: true, if: -> { required_for_step?(:s9) }

  def required_for_step?(step)
    return true if form_step.nil?
    return true if self.form_steps.index(step.to_s) <= self.form_steps.index(form_step)
  end

end
