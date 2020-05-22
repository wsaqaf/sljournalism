class MediaController < ApplicationController
  before_action :check_if_signed_in
  before_action :find_medium, only: [:show, :edit, :update, :destroy]
  before_action :define_types

  def index
    if (params[:sort].present?)
      @sort_msg=sort_bar("Media",params[:sort])
    else
      @sort_msg=sort_bar("Media","td")
    end
    if (params[:term].present?)
      @media = Medium.order(:name).where("(media.sharing_mode=1 OR media.user_id="+current_user.id.to_s+") AND name like ?", "%#{params[:term]}%")
      render json: @media.map(&:name).uniq; return
    elsif (params[:filter]=="r")
      qry="(media.sharing_mode=1 OR media.user_id="+current_user.id.to_s+") AND media.id in (SELECT medium_id FROM medium_reviews WHERE medium_reviews.medium_review_sharing_mode=1 AND medium_reviews.medium_review_verdict IS NOT NULL)"
      @filter_msg=filter_bar("Media","r")
    elsif (params[:filter]=="m")
      qry="media.user_id="+current_user.id.to_s
      @filter_msg=filter_bar("Media","m")
    elsif (params[:filter]=="u")
      qry="(media.sharing_mode=1 OR media.user_id="+current_user.id.to_s+") AND media.id in (SELECT medium_id FROM medium_reviews WHERE medium_reviews.user_id="+current_user.id.to_s+")"
      @filter_msg=filter_bar("Media","u")
    elsif (params[:filter]=="n")
      qry="(media.sharing_mode=1 OR media.user_id="+current_user.id.to_s+") AND NOT EXISTS (SELECT medium_id FROM medium_reviews WHERE media.id=medium_reviews.medium_id AND ((medium_reviews.medium_review_sharing_mode=1 AND medium_reviews.medium_review_verdict IS NOT NULL) OR medium_reviews.user_id="+current_user.id.to_s+"))"
      @filter_msg=filter_bar("Media","n")
    elsif (params[:q].present?)
      @filter_msg=filter_bar("Media","a")
      qry="(media.sharing_mode=1 OR media.user_id="+current_user.id.to_s+") AND (lower(name) like lower('%"+params[:q]+"%') or lower(description) like lower('%"+params[:q]+"%') or lower(url_preview) like lower('%"+params[:q]+"%'))"
    else
      @filter_msg=filter_bar("Media","a")
      if (params[:sort]=="r" or params[:sort]=="rp" or params[:sort]=="rn")
        remove_unsure="";
        if (params[:sort]!="r")
          remove_unsure=" AND medium_reviews.medium_review_verdict!=0 "
        end
        tmp=Medium.joins(:medium_reviews).where("(media.sharing_mode=1 OR media.user_id="+current_user.id.to_s+") AND media.id=medium_reviews.medium_id and medium_reviews.medium_review_sharing_mode=1 and medium_reviews.medium_review_verdict IS NOT NULL"+remove_unsure).group("media.id").order(Arel.sql(sort_statement("medium",params[:sort])))
        @total_count=tmp.count.length
      elsif  (params[:sort]=="rt")
        tmp=Medium.joins(:medium_reviews).where("media.id=medium_reviews.medium_id and (media.sharing_mode=1 OR media.user_id="+current_user.id.to_s+") and medium_reviews.medium_review_sharing_mode=1 and medium_reviews.medium_review_verdict IS NOT NULL").group("media.id,medium_reviews.updated_at,medium_reviews.created_at").order(Arel.sql(sort_statement("medium",params[:sort])))
        @total_count=tmp.count.length
      else
        if qry.nil? then qry="media.sharing_mode=1 OR media.user_id="+current_user.id.to_s; end
        tmp=Medium.where(qry).order(Arel.sql("created_at DESC"))
        @total_count=tmp.count
      end
       @pagy, @media = pagy(tmp, items: 10)
       return
    end
   if (params[:sort]=="r" or params[:sort]=="rp" or params[:sort]=="rn")
     remove_unsure="";
     if (params[:sort]!="r")
       remove_unsure=" AND medium_reviews.medium_review_verdict!=0 "
     end
     tmp=Medium.joins(:medium_reviews).where("(media.sharing_mode=1 OR media.user_id="+current_user.id.to_s+") AND media.id=medium_reviews.medium_id and medium_reviews.medium_review_sharing_mode=1 and medium_reviews.medium_review_verdict IS NOT NULL"+remove_unsure).group("media.id").order(Arel.sql(sort_statement("medium",params[:sort])))
     @total_count=tmp.count.length
   else
     if qry.nil? then qry="media.sharing_mode=1 OR media.user_id="+current_user.id.to_s; end
     tmp=Medium.where(qry).order(Arel.sql("created_at DESC"))
     @total_count=tmp.count
   end
   @pagy, @media = pagy(tmp, items: 10)
  end

  def show
    begin
      @medium_type=@all_medium_types[@medium.medium_type.to_s]
    rescue
      redirect_to root_path
      return
    end
    @warning_msg=""
    dependent_reviews=MediumReview.where("medium_id = ?",@medium.id).count("id")
    if (dependent_reviews>0)
      @warning_msg= t('warning_del_dependents', count:dependent_reviews.to_s)+".\n"
    end
    @warning_msg=@warning_msg+"\n"+t('warning_del')
  end

  def new
    @medium = current_user.media.build
  end

  def create
    start_review=0
    if (!params[:medium].nil?)
      start_review=params[:medium][:start_review]
      params[:medium].delete(:start_review)
    end
    @import_note=""
    if (params[:media_json].present?)
      massport
    elsif (!params[:medium].nil? && (params[:medium][:url] || params[:medium][:file]))
      if (params[:medium][:include_review].present?)
        if (params[:medium][:file].present?)
          myfile=params[:medium][:file]
          file_contents=myfile.read
        else
          myfile=params[:medium][:url]
          require 'open-uri'
          begin
            file_contents= URI.open(myfile) {|f| f.read }
          rescue
            file_contents=""
          end
        end
        if (!file_contents.nil?)
         if (file_contents.length>0)
           begin
            medium_list = JSON.parse(file_contents)
            medium_list.each do |clm|
              @medium = Medium.where("name= ?",clm['name']).first
              if (!@medium.nil?)
                if (params[:medium][:overwrite]=="1" && @medium.user_id==current_user.id)
                  if (params[:medium][:include_review]=="1" && !clm['medium_review'].blank?)
                    @medium_review = MediumReview.where("medium_id=? AND user_id=?",@medium.id,current_user.id).first
                    if (not @medium_review.blank?)
                      @medium_review=MediumReview.find(@medium_review.id)
                      @medium_review.update(clm['medium_review'])
                      @import_note=@import_note+t('medium_review_imported')+"<br>"
                    else
                      current_user.medium_reviews.build(clm['medium_review'])
                    end
                  else
                    clm.delete('medium_review')
                    if (@medium.update(clm))
                      @import_note=@import_note+t('medium_imported')+"<br>"
                    else
                      @import_note=@import_note+t('medium_not_imported')+"<br>"
                    end
                  end
                else
                  @import_note=@import_note+t('medium_not_imported')+"<br>"
                end
              else
                c_rev=clm['medium_review']
                clm.delete('medium_review')
                @medium = current_user.media.build(clm)
                if @medium.save
                  @import_note=@import_note+t('medium_imported')+"<br>"
                  if (!c_rev.blank?)
                    c_rev["medium_id"]= { "medium_id" => @medium.id }
                    @medium_review = MediumReview.new
                    @medium_review.medium_id=@medium.id
                    @medium_review.user_id=current_user.id

                    @medium_review.medium_review_started= c_rev["medium_review_started"]
                    @medium_review.medium_is_blacklisted= c_rev["medium_is_blacklisted"]
                    @medium_review.medium_failed_factcheck_before= c_rev["medium_failed_factcheck_before"]
                    @medium_review.medium_has_poor_security= c_rev["medium_has_poor_security"]
                    @medium_review.medium_whois_info_discrepency= c_rev["medium_whois_info_discrepency"]
                    @medium_review.medium_hosting_discrepency= c_rev["medium_hosting_discrepency"]
                    @medium_review.medium_is_biased= c_rev["medium_is_biased"]
                    @medium_review.medium_is_poorly_ranked= c_rev["medium_is_poorly_ranked"]
                    @medium_review.medium_is_not_liable= c_rev["medium_is_not_liable"]
                    @medium_review.medium_lacks_flagging_means= c_rev["medium_lacks_flagging_means"]
                    @medium_review.medium_other_problems= c_rev["medium_other_problems"]
                    @medium_review.medium_review_is_completed= c_rev["medium_review_is_completed"]
                    @medium_review.note_medium_is_blacklisted= c_rev["note_medium_is_blacklisted"]
                    @medium_review.note_medium_failed_factcheck_before= c_rev["note_medium_failed_factcheck_before"]
                    @medium_review.note_medium_has_poor_security= c_rev["note_medium_has_poor_security"]
                    @medium_review.note_medium_whois_info_discrepency= c_rev["note_medium_whois_info_discrepency"]
                    @medium_review.note_medium_hosting_discrepency= c_rev["note_medium_hosting_discrepency"]
                    @medium_review.note_medium_is_biased= c_rev["note_medium_is_biased"]
                    @medium_review.note_medium_is_poorly_ranked= c_rev["note_medium_is_poorly_ranked"]
                    @medium_review.note_medium_is_not_liable= c_rev["note_medium_is_not_liable"]
                    @medium_review.note_medium_lacks_flagging_means= c_rev["note_medium_lacks_flagging_means"]
                    @medium_review.note_medium_other_problems= c_rev["note_medium_other_problems"]
                    @medium_review.note_medium_review_verdict= c_rev["note_medium_review_verdict"]
                    @medium_review.note_medium_review_description= c_rev["note_medium_review_description"]
                    @medium_review.medium_review_verdict= c_rev["medium_review_verdict"]
                    @medium_review.medium_review_description= c_rev["medium_review_description"]
                    @medium_review.medium_review_sharing_mode= c_rev["medium_review_sharing_mode"]

                    if (@medium_review.save)
                      @import_note=@import_note+t('medium_review_imported')+"<br>"
                    else
                      @import_note=@import_note+t('medium_review_not_imported')+"<br>"
                    end
                  end
                else
                  @import_note=@import_note+t('medium_not_imported')+"<br>"
                end
              end
            end
           rescue
              redirect_to new_medium_path(:import_err => 1)
              return
           end
         end
         render 'show'
        end
      else
        @medium = current_user.media.build(medium_params)
        if @medium.save
            if start_review=="1"
              @medium_review = MediumReview.new
              @medium_review.medium_id=@medium.id
              @medium_review.user_id=current_user.id
              @medium_review.save(validate: false)
              redirect_to medium_medium_review_step_path(@medium,@medium_review, MediumReview.form_steps.first)
            else
              redirect_to media_path
            end
        else
            render 'new'
        end
      end
    else
      @medium = current_user.media.build(medium_params)
      if @medium.save
        if start_review==1
          @medium_review = MediumReview.new
          @medium_review.medium_id=@medium.id
          @medium_review.user_id=current_user.id
          @medium_review.save(validate: false)
          redirect_to medium_medium_review_step_path(@medium,@medium_review, MediumReview.form_steps.first)
        else
          redirect_to media_path
        end
      else
          render 'new'
      end
    end
  end


  def edit
    if current_user.id!=@medium.user_id && current_user.role!="admin"
      redirect_to medium_path(@medium)
    end
  end

  def update
    if current_user.id!=@medium.user_id && current_user.role!="admin"
      redirect_to medium_path(@medium)
      return
    end
    if @medium.update(medium_params)
      redirect_to medium_path(@medium)
    else
      render 'edit'
    end
  end

  def destroy
    Claim.where("medium_id = ?",@medium.id).update_all(medium_id: nil)
    MediumReview.where("medium_id = ?",@medium.id).destroy_all
    @medium.destroy
    redirect_to media_path
  end

  def export
      if (!params[:id].blank?)
          clm=Medium.find(params[:id])
          result_json=[]
          medium_rev={}
          clm_review = MediumReview.where("medium_id=? AND medium_review_sharing_mode=1",clm.id).first
          if (!clm_review.blank?)
            medium_rev={
              "medium_review_started" => clm_review.medium_review_started,
              "medium_is_blacklisted" => clm_review.medium_is_blacklisted,
              "medium_failed_factcheck_before" => clm_review.medium_failed_factcheck_before,
              "medium_has_poor_security" => clm_review.medium_has_poor_security,
              "medium_whois_info_discrepency" => clm_review.medium_whois_info_discrepency,
              "medium_hosting_discrepency" => clm_review.medium_hosting_discrepency,
              "medium_is_biased" => clm_review.medium_is_biased,
              "medium_is_poorly_ranked" => clm_review.medium_is_poorly_ranked,
              "medium_is_not_liable" => clm_review.medium_is_not_liable,
              "medium_lacks_flagging_means" => clm_review.medium_lacks_flagging_means,
              "medium_other_problems" => clm_review.medium_other_problems,
              "medium_review_is_completed" => clm_review.medium_review_is_completed,
              "note_medium_is_blacklisted" => clm_review.note_medium_is_blacklisted,
              "note_medium_failed_factcheck_before" => clm_review.note_medium_failed_factcheck_before,
              "note_medium_has_poor_security" => clm_review.note_medium_has_poor_security,
              "note_medium_whois_info_discrepency" => clm_review.note_medium_whois_info_discrepency,
              "note_medium_hosting_discrepency" => clm_review.note_medium_hosting_discrepency,
              "note_medium_is_biased" => clm_review.note_medium_is_biased,
              "note_medium_is_poorly_ranked" => clm_review.note_medium_is_poorly_ranked,
              "note_medium_is_not_liable" => clm_review.note_medium_is_not_liable,
              "note_medium_lacks_flagging_means" => clm_review.note_medium_lacks_flagging_means,
              "note_medium_other_problems" => clm_review.note_medium_other_problems,
              "note_medium_review_verdict" => clm_review.note_medium_review_verdict,
              "note_medium_review_description" => clm_review.note_medium_review_description,
              "medium_review_verdict" => clm_review.medium_review_verdict,
              "medium_review_description" => clm_review.medium_review_description,
              "medium_review_sharing_mode" => clm_review.medium_review_sharing_mode
              }
          end
          medium_json = {
            "name" => clm.name,
            "url" => clm.url,
            "url_preview" => clm.url_preview,
            "description" => clm.description,
            "medium_type" => clm.medium_type,
            "sharing_mode" => clm.sharing_mode,
            "medium_review" => medium_rev
          }
          result_json << medium_json
          send_data result_json.to_json,
            :type => 'text/json; charset=UTF-8;',
            :disposition => "attachment; filename=medium"+params[:id].to_s+".json"
      end
  end

  private


  def massport
    media_json=params[:media_json]
    send_data media_json,
      :type => 'text/json; charset=UTF-8;',
      :disposition => "attachment; filename=media.json"
  end

  def get_all_json
    @media_json = []
    @tmp.all.each do |clm|
      clm_json = {
        "name" => clm.name,
        "description" => clm.description,
        "url" => clm.url,
        "url_preview" => clm.url_preview,
        "medium_type" => clm.medium_type,
        "sharing_mode" => 1,
        "medium_review" => medium_rev
      }
      @media_json << clm_json
    end
    @media_json = @media_json.to_json
    @media_json=@media_json.to_s;
  end

  def medium_params
    params.require(:medium).permit(:name, :url, :medium_type, :description, :sharing_mode, :url_preview, :start_review)
  end

  def find_medium
      @medium = Medium.where("id=? AND (media.sharing_mode=1 OR media.user_id="+current_user.id.to_s+")",params[:id]).first
  end

  def define_types
    @all_medium_types={"1"=>t('medium_type_social_media'),"2"=>t('medium_type_news'),"3"=>t('medium_type_im'),"4"=>t('medium_type_video'),"5"=>t('medium_type_blog'),"100"=>t('medium_type_other')}
    @medium_types=[]
    @medium_types.push(['Select',''])
    @all_medium_types.each do |key, value|
      @medium_types.push([value,key])
    end
  end

end
