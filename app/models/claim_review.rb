class ClaimReview < ApplicationRecord
  belongs_to :user
  belongs_to :claim

  cattr_accessor :form_steps do
  ########Step Names#########
  %w(s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 s17 s18 s19 s20 s21 s22)
  ########Step Names#########
    end

    attr_accessor :form_step

    ########Step Validation#########
#    validates :review_verdict, presence: true, if: -> { required_for_step?(:s21) }
#    validates :review_sharing_mode, presence: true, if: -> { required_for_step?(:s22) }
    ########Step Validation#########

    def required_for_step?(step)
      return true if form_step.nil?
      return true if self.form_steps.index(step.to_s) <= self.form_steps.index(form_step)
    end

    def medium_name
      medium.try(:name)
    end

    def medium_exists
      if (Medium.find(name: name) != nil)
        return true
      else
        return false
      end
    end

    def medium_name=(name)
      self.medium = Medium.create_with(user_id: User.current_user.id).find_or_create_by(name: name) if name.present?
    end

    def src_name
      src.try(:name)
    end

    def src_name=(name)
      self.src = Src.create_with(user_id: User.current_user.id).find_or_create_by(name: name) if name.present?
    end


end
