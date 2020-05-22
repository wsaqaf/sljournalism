class SrcReviewsController < ApplicationController
  before_action :find_src
  before_action :check_if_signed_in

  def index
    if (params[:term].present?)
      @src_reviews = SrcReview.order(:id).where("name like ?", "%#{params[:term]}%")
      render json: @src_reviews.map(&:name).uniq
    else
      @src_reviews = SrcReview.all.order(Arel.sql("created_at DESC")).where("src_id=? AND ((src_review_sharing_mode=1 AND src_review_verdict IS NOT NULL) OR user_id=?)",@src.id,current_user.id)
    end
  end

  def show
    @tmp = SrcReview.where("id=? AND (src_review_sharing_mode=1 OR user_id=?)",params[:id],current_user.id).first
    if (not @tmp.blank?)
      @src_review=SrcReview.find(@tmp.id)
    else
      redirect_to srcs_path
    end
  end

  def new
  end

  def create
    @tmp = SrcReview.where("src_id=? AND user_id=?",@src.id,current_user.id).first
    if (not @tmp.blank?)
      @src_review=SrcReview.find(@tmp.id)
      redirect_to src_src_review_step_path(@src,@src_review, SrcReview.form_steps.first)
      return
    end
    @src_review = SrcReview.new
    @src_review.src_id=@src.id
    @src_review.user_id=current_user.id

    @src_review.save(validate: false)
    redirect_to src_src_review_step_path(@src,@src_review, SrcReview.form_steps.first)
  end

  def edit
    @tmp = SrcReview.where("src_id=? AND user_id=?",@src.id,current_user.id).first
    if (@tmp.blank?)
      @src_review=SrcReview.find(@tmp.id)
      if current_user.id!=@src_review.user_id
        redirect_to src_src_review_path(@src,@src_review)
      end
    else
      redirect_to src_path(@src)
    end
  end

  def update
    @tmp = SrcReview.where("src_id=? AND user_id=?",@src.id,current_user.id).first
    if (not @tmp.blank?)
      @src_review=SrcReview.find(@tmp.id)
      @src_review.update(src_review_params)
    end
    redirect_to src_src_review_path(@src,@src_review)
  end

  def destroy
    @tmp = SrcReview.where("src_id=? AND user_id=?",@src.id,current_user.id).first
    if (not @tmp.blank?)
      @src_review=SrcReview.find(@tmp.id)
      @src_review.destroy
    end
    redirect_to srcs_path
  end

  private

  def find_src
    @src = Src.find(params[:src_id])
  end

    def src_review_params
      params.require(:src_review).permit(:id, :src_lacks_proper_credentials, :note_src_lacks_proper_credentials, :src_failed_factcheck_before, :note_src_failed_factcheck_before, :src_has_poor_writing_history, :note_src_has_poor_writing_history, :src_supported_by_trolls, :note_src_supported_by_trolls, :src_difficult_to_locate, :note_src_difficult_to_locate, :src_other_problems, :note_src_other_problems, :src_review_verdict, :src_review_description, :note_src_review_description, :src_review_sharing_mode, :note_src_review_sharing_mode)
      end
end
