class MediumReviewsController < ApplicationController
  before_action :find_medium
  before_action :check_if_signed_in


  def index
      @medium_reviews = MediumReview.all.order(Arel.sql("created_at DESC")).where("medium_id=? AND ((medium_review_sharing_mode=1 AND medium_review_verdict IS NOT NULL) OR  user_id=?)",@medium.id,current_user.id)
  end

  def show
    @tmp = MediumReview.where("id=? AND (medium_review_sharing_mode=1 OR user_id=?)",params[:id],current_user.id).first
    if (not @tmp.blank?)
      @medium_review=MediumReview.find(@tmp.id)
    else
      redirect_to media_path
    end
  end

  def new
  end

  def create
    @tmp = MediumReview.where(user_id: current_user.id, medium_id: @medium.id).select("id").first
    if (not @tmp.blank?)
      @medium_review=MediumReview.find(@tmp.id)
      redirect_to medium_medium_review_step_path(@medium,@medium_review, MediumReview.form_steps.first)
      return
    end
    @medium_review = MediumReview.new
    @medium_review.medium_id=@medium.id
    @medium_review.user_id=current_user.id
    @medium_review.save(validate: false)
    redirect_to medium_medium_review_step_path(@medium,@medium_review, MediumReview.form_steps.first)
  end

  def edit
    @tmp = MediumReview.where("medium_id=? AND user_id=?",@medium.id,current_user.id).first
    if (@tmp.blank?)
      @medium_review=MediumReview.find(@tmp.id)
      if current_user.id!=@medium_review.user_id
        redirect_to medium_medium_review_path(@medium,@medium_review)
      end
    else
      redirect_to medium_path(@medium)
    end
  end

  def update
    @tmp = MediumReview.where("medium_id=? AND user_id=?",@medium.id,current_user.id).first
    if (not @tmp.blank?)
      @medium_review=MediumReview.find(@tmp.id)
      @medium_review.update(medium_review_params)
    end
    redirect_to medium_medium_review_path(@medium,@medium_review)
  end

  def destroy
    @tmp = MediumReview.where("medium_id=? AND user_id=?",@medium.id,current_user.id).first
    if (not @tmp.blank?)
      @medium_review=MediumReview.find(@tmp.id)
      @medium_review.destroy
    end
    redirect_to media_path
  end

  private

  def find_medium
    @medium = Medium.find(params[:medium_id])
  end

  def medium_review_params
    params.require(:medium_review).permit(:id, :medium_is_blacklisted, :note_medium_is_blacklisted, :medium_failed_factcheck_before, :note_medium_failed_factcheck_before, :medium_has_poor_security, :note_medium_has_poor_security, :medium_whois_info_discrepency, :note_medium_whois_info_discrepency, :medium_hosting_discrepency, :note_medium_hosting_discrepency, :medium_is_biased, :note_medium_is_biased, :medium_is_poorly_ranked, :note_medium_is_poorly_ranked, :medium_is_not_liable, :note_medium_is_not_liable, :medium_lacks_flagging_means, :note_medium_lacks_flagging_means, :medium_other_problems, :note_medium_other_problems, :medium_review_verdict, :medium_review_description, :note_medium_review_description, :medium_review_sharing_mode, :note_medium_review_sharing_mode)
  end

end
