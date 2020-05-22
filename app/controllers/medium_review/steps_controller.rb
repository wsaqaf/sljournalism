class MediumReview::StepsController < ApplicationController
  include Wicked::Wizard
  before_action :find_medium
  before_action :check_if_signed_in
  helper_method :is_visible
#  skip_before_action :verify_authenticity_token

  steps *MediumReview.form_steps

  def get_score(field)
    total=0
    score=0
    confidence=0
    result=""
    if field=="medium"
      adj1="reliable"
      adj2="unreliable"
      fields=[@medium_review.medium_is_blacklisted,@medium_review.medium_failed_factcheck_before,@medium_review.medium_has_poor_security,@medium_review.medium_whois_info_discrepency,@medium_review.medium_hosting_discrepency,@medium_review.medium_is_biased,@medium_review.medium_is_poorly_ranked,@medium_review.medium_is_not_liable,@medium_review.medium_lacks_flagging_means,@medium_review.medium_other_problems]
      fields.each { |f| if (f.present? and not f.blank? and f!=0) then score=score+f.to_i; total=total+1; end }
    elsif field=="src"
      adj1="trustworthy"
      adj2="untrustworthy"
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
    @medium_review = MediumReview.find(params[:medium_review_id])
    @no_turbolinks= "false";
    if step=="s11" then @medium_review_score=get_score("medium")
    elsif step=="s12" then @no_turbolinks= "true"; end
    render_wizard

  end

  def update
      @medium_review = MediumReview.find(params[:medium_review_id])

      begin
        @medium_review.update(medium_review_params(step).merge(user_id: current_user.id))
      rescue
        return
      end

      if (params['commit']==t('previous_step'))
          redirect_to previous_wizard_path+'?s=prev'
          return
      elsif (params['commit']!= t('next_step') && params['commit']!=t('finish'))
        all_steps_r=@all_steps.invert
        redirect_to wizard_path(all_steps_r[params['commit']])
        return
      end

      if step=="s10" then @medium_review_score=get_score("medium")  end

      if step=="s13"
         if !params[:medium_review][:medium_review_sharing_mode].blank? then redirect_to media_path;
         else render_wizard @medium_review end
      else render_wizard @medium_review end
###Step conditions###
  end


    def is_visible(st)
          return '<div class="divTableRow">'
    end

  private
  def find_medium
    @medium = Medium.find(params[:medium_id])

    @all_steps={'s1'=>t('medium_is_blacklisted_q_short'),'s2'=>t('medium_failed_factcheck_before_q_short'),'s3'=>t('medium_has_poor_security_q_short'),'s4'=>t('medium_whois_info_discrepency_q_short'),'s5'=>t('medium_hosting_discrepency_q_short'),'s6'=>t('medium_is_biased_q_short'),'s7'=>t('medium_is_poorly_ranked_q_short'),'s8'=>t('medium_is_not_liable_q_short'),'s9'=>t('medium_lacks_flagging_means_q_short'),'s10'=>t('medium_other_problems_q_short'),'s11'=>t('calculated_score_q_short'),'s12'=>t('review_verdict_q_short'),'s12'=>t('review_description_q_short'),'s13'=>t('share_setting_brief')}

  end

    def medium_review_params(step)
      permitted_attributes = case step
########StepsToDo#########
when "s1"
  [:medium_is_blacklisted, :note_medium_is_blacklisted]
when "s2"
  [:medium_failed_factcheck_before, :note_medium_failed_factcheck_before]
when "s3"
  [:medium_has_poor_security, :note_medium_has_poor_security]
when "s4"
  [:medium_whois_info_discrepency, :note_medium_whois_info_discrepency]
when "s5"
  [:medium_hosting_discrepency, :note_medium_hosting_discrepency]
when "s6"
  [:medium_is_biased, :note_medium_is_biased]
when "s7"
  [:medium_is_poorly_ranked, :note_medium_is_poorly_ranked]
when "s8"
  [:medium_is_not_liable, :note_medium_is_not_liable]
when "s9"
  [:medium_lacks_flagging_means, :note_medium_lacks_flagging_means]
when "s10"
  [:medium_other_problems, :note_medium_other_problems]
when "s12"
  [:medium_review_verdict, :medium_review_description, :note_medium_review_description]
when "s13"
  [:medium_review_sharing_mode, :note_medium_review_sharing_mode]

########StepsToDo#########
      end
      begin
        params.require(:medium_review).permit(permitted_attributes).merge(form_step: step)
      rescue
        render_wizard
        return
      end
    end

end
