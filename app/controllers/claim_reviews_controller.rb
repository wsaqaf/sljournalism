class ClaimReviewsController < ApplicationController
  before_action :find_claim
  before_action :check_if_signed_in

  def index
      @claim_reviews = ClaimReview.all.order(Arel.sql("created_at DESC")).where("claim_id=? AND ((review_sharing_mode=1 AND review_verdict IS NOT NULL) OR user_id=?)",@claim.id,current_user.id)
  end

  def show
    @tmp = ClaimReview.where("id=? AND (review_sharing_mode=1 OR user_id=?)",params[:id],current_user.id).first
    if (not @tmp.blank?)
      @claim_review=ClaimReview.find(@tmp.id)
    else
      redirect_to claims_path
    end
  end

  def new
  end

  def create
    @tmp = ClaimReview.where("claim_id=? AND user_id=?",@claim.id,current_user.id).first
    if (not @tmp.blank?)
      @claim_review=ClaimReview.find(@tmp.id)
      redirect_to claim_claim_review_step_path(@claim,@claim_review, ClaimReview.form_steps.first)
      return
    end
    @claim_review = ClaimReview.new
    @claim_review.claim_id=@claim.id
    @claim_review.user_id=current_user.id
    @claim_review.save(validate: false)
    redirect_to claim_claim_review_step_path(@claim,@claim_review, ClaimReview.form_steps.first)
  end

  def edit
    @tmp = ClaimReview.where("claim_id=? AND user_id=?",@claim.id,current_user.id).first
    if (@tmp.blank?)
      @claim_review=ClaimReview.find(@tmp.id)
      if current_user.id!=@claim_review.user_id
        redirect_to claim_claim_review_path(@claim,@claim_review)
      end
    else
      redirect_to claim_path(@claim)
    end
  end

  def update
    if (!params.has_key?(:claim_review)) then redirect_to claims_path; return; end

    @tmp = ClaimReview.where("claim_id=? AND user_id=?",@claim.id,current_user.id).first
    if (not @tmp.blank?)
      @claim_review=ClaimReview.find(@tmp.id)
      @claim_review.update(claim_review_params)
    end
    redirect_to claims_path;
  end

  def destroy
    @tmp = ClaimReview.where("claim_id=? AND user_id=?",@claim.id,current_user.id).first
    if (not @tmp.blank?)
      @claim_review=ClaimReview.find(@tmp.id)
      @claim_review.destroy
    end
    redirect_to claims_path
  end

  private

  def check_ownership
  end

  def find_claim
    @claim = Claim.find(params[:claim_id])
  end

  def claim_review_params
        params.require(:claim_review).permit(:id, :img_review_started, :img_old, :note_img_old, :img_forensic_discrepency, :note_img_forensic_discrepency, :img_metadata_discrepency, :note_img_metadata_discrepency, :img_logical_discrepency, :note_img_logical_discrepency, :vid_review_started, :vid_old, :note_vid_old, :vid_forensic_discrepency, :note_vid_forensic_discrepency, :vid_metadata_discrepency, :note_vid_metadata_discrepency, :vid_audio_discrepency, :note_vid_audio_discrepency, :vid_logical_discrepency, :note_vid_logical_discrepency, :txt_review_started, :txt_unreliable_news_content, :note_txt_unreliable_news_content, :txt_insufficient_verifiable_srcs, :note_txt_insufficient_verifiable_srcs, :txt_has_clickbait, :note_txt_has_clickbait, :txt_poor_language, :note_txt_poor_language, :txt_crowds_distance_discrepency, :note_txt_crowds_distance_discrepency, :txt_author_offers_little_evidence, :note_txt_author_offers_little_evidence, :txt_reliable_sources_disapprove, :note_txt_reliable_sources_disapprove, :review_verdict, :review_description, :note_review_description, :review_sharing_mode, :note_review_sharing_mode, :save_to_blockchain)
  end

end
