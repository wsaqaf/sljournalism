class MediumReview < ApplicationRecord
  belongs_to :user
  belongs_to :medium

  cattr_accessor :form_steps do
  ########Step Names#########
  %w(s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13)
  ########Step Names#########
    end

    attr_accessor :form_step

    validates :medium_review_verdict, presence: true, if: -> { required_for_step?(:s12) }
    validates :medium_review_sharing_mode, presence: true, if: -> { required_for_step?(:s13) }

    def required_for_step?(step)
      return true if form_step.nil?
      return true if self.form_steps.index(step.to_s) <= self.form_steps.index(form_step)
    end

end
