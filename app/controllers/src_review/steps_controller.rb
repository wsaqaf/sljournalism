class SrcReview::StepsController < ApplicationController
  include Wicked::Wizard
  before_action :find_src
  helper_method :is_visible
#  skip_before_action :verify_authenticity_token

  steps *SrcReview.form_steps

  def get_score(field)
    total=0
    score=0
    confidence=0
    result=""
    if field=="medium"
      adj1="reliable"
      adj2="unreliable"
    elsif field=="src"
      adj1="trustworthy"
      adj2="untrustworthy"
      fields=[@src_review.src_lacks_proper_credentials,@src_review.src_failed_factcheck_before,@src_review.src_has_poor_writing_history,@src_review.src_supported_by_trolls,@src_review.src_difficult_to_locate,@src_review.src_other_problems]
      fields.each { |f| if (f.present? and not f.blank? and f!=0) then score=score+f.to_i; total=total+1; end }
    else
      adj1="valid"
      adj2="invalid"
    end
    max_total=fields.count
    if (score==0 || total==0 || max_total==0)
        score=0; total=0; max_total=1;
    end;
    confidence=(100*(total.to_f/max_total)).to_i
    relative_score=t('score_is1')+score.to_s+t('score_is2')+max_total.to_s
    if (score==-1*max_total)
      relative_score=t('rate_totally_'+adj2)
    elsif (score<=-0.5*max_total)
      relative_score=t('rate_mostly_'+adj2)
    elsif (score<0)
      relative_score=t('rate_somewhat_'+adj2)
    elsif (score==0)
      relative_score=t('rate_somewhat_'+adj2)
    elsif (score<=0.5*max_total)
      relative_score=t('rate_not_measurable')
    elsif (score<max_total)
      relative_score=t('rate_mostly_'+adj1)
    elsif (score==max_total)
      relative_score=t('rate_totally_'+adj1)
    end
    result=t('score_result1')+total.to_s+t('score_result2')+max_total.to_s+" (%"+confidence.to_s+"),"+t('score_result3')+field+t('score_result4')+"<b>("+relative_score+")</b>"+t('score_result5')+"<br><br>"
    if score==max_total then score=score-0.1 elsif score==-1*max_total then score=score+0.1 end
    result=result+"<p style='text-align:center;line-height:30px;font-size:20'><b>"+t('least')+t(adj1)+"</b> <meter max="+max_total.to_s+" min=-"+max_total.to_s+" value="+score.to_s+" high="+(max_total*0.5).to_s+" low=0.00 optimum="+max_total.to_s+" style='width: 400px;height:15px;'></meter>"+" <b>"+t('most')+t(adj1)+"</b><br><br>"+t('assessment_of')+t('the_'+field)+": "+relative_score+"</b></p>"
    return result
  end

  def show
    @src_review = SrcReview.find(params[:src_review_id])
    @no_turbolinks= "false";

    if step=="s7" then @src_review_score=get_score("src")
    elsif step=="s8" then @no_turbolinks= "true"; end
    render_wizard
  end

  def update
      @src_review = SrcReview.find(params[:src_review_id])

      begin
        @src_review.update(src_review_params(step).merge(user_id: current_user.id))
      rescue
        return
      end

      if (params['commit']==t('previous_step'))
          redirect_to previous_wizard_path+'?s=prev'
          return
      elsif (params['commit']!=t('next_step') && params['commit']!=t('finish'))
        all_steps_r=@all_steps.invert
        redirect_to wizard_path(all_steps_r[params['commit']])
        return
      end

      if step=="s6" then @src_review_score=get_score("src") end
      if step=="s9"
        if !params[:src_review][:src_review_sharing_mode].blank? then redirect_to srcs_path;
        else render_wizard @src_review end
      else render_wizard @src_review end
###Step conditions###
  end

  def is_visible(st)
        return '<div class="divTableRow">'
  end

  private
  def find_src
    @src = Src.find(params[:src_id])

    @all_steps={'s1'=>t('src_credentials_q_short'),'s2'=>t('src_factcheck_history_q_short'),'s3'=>t('src_quality_of_writing_q_short'),'s4'=>t('src_connected_to_biased_entities_q_short'),'s5'=>t('src_difficulty_to_verify_auth_q_short'),'s6'=>t('src_other_problems_q_short'),'s7'=>t('calculated_score_q_short'),'s8'=>t('review_verdict_q_short'),'s8'=>t('review_description_q_short'),'s9'=>t('share_setting_brief')}

  end

    def src_review_params(step)
      permitted_attributes = case step
########StepsToDo#########
when "s1"
  [:src_lacks_proper_credentials, :note_src_lacks_proper_credentials]
when "s2"
  [:src_failed_factcheck_before, :note_src_failed_factcheck_before]
when "s3"
  [:src_has_poor_writing_history, :note_src_has_poor_writing_history]
when "s4"
  [:src_supported_by_trolls, :note_src_supported_by_trolls]
when "s5"
  [:src_difficult_to_locate, :note_src_difficult_to_locate]
when "s6"
  [:src_other_problems, :note_src_other_problems]
when "s8"
  [:src_review_verdict, :src_review_description, :note_src_review_description]
when "s9"
  [:src_review_sharing_mode, :note_src_review_sharing_mode]
########StepsToDo#########
end
    begin
      params.require(:src_review).permit(permitted_attributes).merge(form_step: step)
    rescue
      render_wizard
      return
    end
  end

end
