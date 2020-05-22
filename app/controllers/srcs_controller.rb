class SrcsController < ApplicationController
  before_action :find_src, only: [:show, :edit, :update, :destroy]
  before_action :define_types
  before_action :check_if_signed_in

  def index
    if (params[:sort].present?)
      @sort_msg=sort_bar("Srcs",params[:sort])
    else
      @sort_msg=sort_bar("Srcs","td")
    end
    if (params[:term].present?)
      @srcs = Src.order(:name).where("name like ? AND (srcs.sharing_mode=1 OR srcs.user_id="+current_user.id.to_s+") ", "%#{params[:term]}%")
      render json: @srcs.map(&:name).uniq; return
    elsif (params[:filter]=="r")
      qry="srcs.id in (SELECT src_id FROM src_reviews WHERE (srcs.sharing_mode=1 OR srcs.user_id="+current_user.id.to_s+") AND src_reviews.src_review_sharing_mode=1 AND src_reviews.src_review_verdict IS NOT NULL)"
      @filter_msg=filter_bar("Srcs","r")
    elsif (params[:filter]=="m")
      qry="srcs.user_id="+current_user.id.to_s
      @filter_msg=filter_bar("Srcs","m")
    elsif (params[:filter]=="u")
      qry="srcs.id in (SELECT src_id FROM src_reviews WHERE (srcs.sharing_mode=1 OR srcs.user_id="+current_user.id.to_s+") AND src_reviews.user_id="+current_user.id.to_s+")"
      @filter_msg=filter_bar("Srcs","u")
    elsif (params[:filter]=="n")
      qry="(srcs.sharing_mode=1 OR srcs.user_id="+current_user.id.to_s+") AND NOT EXISTS (SELECT src_id FROM src_reviews WHERE srcs.id=src_reviews.src_id AND ((src_reviews.src_review_sharing_mode=1 AND src_reviews.src_review_verdict IS NOT NULL) OR src_reviews.user_id="+current_user.id.to_s+"))"
      @filter_msg=filter_bar("Srcs","n")
    elsif (params[:q].present?)
      @filter_msg=filter_bar("Srcs","a")
      qry="(srcs.sharing_mode=1 OR srcs.user_id="+current_user.id.to_s+") AND (lower(name) like lower('%"+params[:q]+"%') or lower(description) like lower('%"+params[:q]+"%') or lower(url_preview) like lower('%"+params[:q]+"%'))"
    else
      @filter_msg=filter_bar("Srcs","a")
      if (params[:sort]=="r" or params[:sort]=="rp" or params[:sort]=="rn")
        remove_unsure="";
        if (params[:sort]!="r")
          remove_unsure=" AND src_reviews.src_review_verdict!=0 "
        end
        tmp=Src.joins(:src_reviews).where("(srcs.sharing_mode=1 OR srcs.user_id="+current_user.id.to_s+") AND srcs.id=src_reviews.src_id and src_reviews.src_review_sharing_mode=1 and src_reviews.src_review_verdict IS NOT NULL"+remove_unsure).group("srcs.id").order(Arel.sql(sort_statement("src",params[:sort])))
        @total_count=tmp.count.length
      elsif  (params[:sort]=="rt")
        tmp=Src.joins(:src_reviews).where("srcs.id=src_reviews.src_id and (srcs.sharing_mode=1 OR srcs.user_id="+current_user.id.to_s+") and src_reviews.src_review_sharing_mode=1 and src_reviews.src_review_verdict IS NOT NULL").group("srcs.id,src_reviews.updated_at,src_reviews.created_at").order(Arel.sql(sort_statement("src",params[:sort])))
        @total_count=tmp.count.length
      else
        if qry.nil? then qry="srcs.sharing_mode=1 OR srcs.user_id="+current_user.id.to_s; end
        tmp=Src.where(qry).order(Arel.sql("created_at DESC"))
        @total_count=tmp.count
      end
       @pagy, @srcs = pagy(tmp, items: 10)
       return
    end
   if (params[:sort]=="r" or params[:sort]=="rp" or params[:sort]=="rn")
     remove_unsure="";
     if (params[:sort]!="r")
       remove_unsure=" AND src_reviews.src_review_verdict!=0 "
     end
     tmp=Src.joins(:src_reviews).where("(srcs.sharing_mode=1 OR srcs.user_id="+current_user.id.to_s+") AND srcs.id=src_reviews.src_id and src_reviews.src_review_sharing_mode=1 and src_reviews.src_review_verdict IS NOT NULL"+remove_unsure).group("srcs.id").order(Arel.sql(sort_statement("src",params[:sort])))
     @total_count=tmp.count.length
   else
     if qry.nil? then qry="srcs.sharing_mode=1 OR srcs.user_id="+current_user.id.to_s; end
     tmp=Src.where(qry).order(Arel.sql("created_at DESC"))
     @total_count=tmp.count
   end
     @pagy, @srcs = pagy(tmp, items: 10)
  end

  def show
    begin
      @src_type=@all_src_types[@src.src_type.to_s]
    rescue
      redirect_to root_path
      return
    end
    @warning_msg=""
    dependent_reviews=SrcReview.where("src_id = ?",@src.id).count("id")
    if (dependent_reviews>0)
      @warning_msg= t('warning_del_dependents', count:dependent_reviews.to_s)+".\n"
    end
    @warning_msg=@warning_msg+"\n"+t('warning_del')
  end

  def new
    @src = current_user.srcs.build
  end

  def create
    start_review=0
    if (!params[:src].nil?)
      start_review=params[:src][:start_review]
      params[:src].delete(:start_review)
    end
    @import_note=""
    if (params[:srcs_json].present?)
      massport
    elsif (!params[:src].nil? && (params[:src][:url] || params[:src][:file]))
      if (params[:src][:include_review].present?)
        if (params[:src][:file].present?)
          myfile=params[:src][:file]
          file_contents=myfile.read
        else
          myfile=params[:src][:url]
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
            src_list = JSON.parse(file_contents)
            src_list.each do |clm|
              @src = Src.where("name= ?",clm['name']).first
              if (!@src.nil?)
                if (params[:src][:overwrite]=="1" && @src.user_id==current_user.id)
                  if (params[:src][:include_review]=="1" && !clm['src_review'].blank?)
                    @src_review = SrcReview.where("src_id=? AND user_id=?",@src.id,current_user.id).first
                    if (not @src_review.blank?)
                      @src_review=SrcReview.find(@src_review.id)
                      @src_review.update(clm['src_review'])
                      @import_note=@import_note+t('src_review_imported')+"<br>"
                    else
                      current_user.src_reviews.build(clm['src_review'])
                    end
                  else
                    clm.delete('src_review')
                    if (@src.update(clm))
                      @import_note=@import_note+t('src_imported')+"<br>"
                    else
                      @import_note=@import_note+t('src_not_imported')+"<br>"
                    end
                  end
                else
                  @import_note=@import_note+t('src_not_imported')+"<br>"
                end
              else
                c_rev=clm['src_review']
                clm.delete('src_review')
                @src = current_user.srcs.build(clm)
                if @src.save
                  @import_note=@import_note+t('src_imported')+"<br>"
                  if (!c_rev.blank?)
                    c_rev["src_id"]= { "src_id" => @src.id }
                    @src_review = SrcReview.new
                    @src_review.src_id=@src.id
                    @src_review.user_id=current_user.id

                    @src_review.src_review_started= c_rev["src_review_started"]
                    @src_review.src_lacks_proper_credentials= c_rev["src_lacks_proper_credentials"]
                    @src_review.src_failed_factcheck_before= c_rev["src_failed_factcheck_before"]
                    @src_review.src_has_poor_writing_history= c_rev["src_has_poor_writing_history"]
                    @src_review.src_supported_by_trolls= c_rev["src_supported_by_trolls"]
                    @src_review.src_difficult_to_locate= c_rev["src_difficult_to_locate"]
                    @src_review.src_other_problems= c_rev["src_other_problems"]
                    @src_review.src_review_verdict= c_rev["src_review_verdict"]
                    @src_review.src_review_description= c_rev["src_review_description"]
                    @src_review.src_review_sharing_mode= c_rev["src_review_sharing_mode"]
                    @src_review.src_review_is_completed= c_rev["src_review_is_completed"]
                    @src_review.note_src_lacks_proper_credentials= c_rev["note_src_lacks_proper_credentials"]
                    @src_review.note_src_failed_factcheck_before= c_rev["note_src_failed_factcheck_before"]
                    @src_review.note_src_has_poor_writing_history= c_rev["note_src_has_poor_writing_history"]
                    @src_review.note_src_supported_by_trolls= c_rev["note_src_supported_by_trolls"]
                    @src_review.note_src_difficult_to_locate= c_rev["note_src_difficult_to_locate"]
                    @src_review.note_src_other_problems= c_rev["note_src_other_problems"]
                    @src_review.note_src_review_verdict= c_rev["note_src_review_verdict"]
                    @src_review.note_src_review_description= c_rev["note_src_review_description"]
                    @src_review.note_src_review_sharing_mode= c_rev["note_src_review_sharing_mode"]

                    if (@src_review.save)
                      @import_note=@import_note+t('src_review_imported')+"<br>"
                    else
                      @import_note=@import_note+t('src_review_not_imported')+"<br>"
                    end
                  end
                else
                  @import_note=@import_note+t('src_not_imported')+"<br>"
                end
              end
            end
           rescue
             redirect_to new_src_path(:import_err => 1)
             return
           end
         end
         render 'show'
        end
      else
        @src = current_user.srcs.build(src_params)
        if @src.save
            if start_review=="1"
              @src_review = SrcReview.new
              @src_review.src_id=@src.id
              @src_review.user_id=current_user.id
              @src_review.save(validate: false)
              redirect_to src_src_review_step_path(@src,@src_review, SrcReview.form_steps.first)
            else
              redirect_to srcs_path
            end
        else
            render 'new'
        end
      end
    else
      @src = current_user.srcs.build(src_params)
      if @src.save
        if start_review==1
          @src_review = SrcReview.new
          @src_review.src_id=@src.id
          @src_review.user_id=current_user.id
          @src_review.save(validate: false)
          redirect_to src_src_review_step_path(@src,@src_review, SrcReview.form_steps.first)
        else
          redirect_to srcs_path
        end
      else
          render 'new'
      end
    end
  end

  def edit
    if current_user.id!=@src.user_id && current_user.role!="admin"
      redirect_to src_path(@src)
    end
  end

  def update
    if current_user.id!=@src.user_id && current_user.role!="admin"
      redirect_to src_path(@src)
      return
    end
    if @src.update(src_params)
      redirect_to src_path(@src)
    else
      render 'edit'
    end
  end

  def destroy
    Claim.where("src_id = ?",@src.id).update_all(src_id: nil)
    SrcReview.where("src_id = ?",@src.id).destroy_all
    @src.destroy
    redirect_to srcs_path
  end

  def export
      if (!params[:id].blank?)
          clm=Src.find(params[:id])
          result_json=[]
          src_rev={}
          clm_review = SrcReview.where("src_id=? AND src_review_sharing_mode=1",clm.id).first
          if (!clm_review.blank?)
            src_rev={
            "src_review_started" => clm_review.src_review_started,
            "src_lacks_proper_credentials" => clm_review.src_lacks_proper_credentials,
            "src_failed_factcheck_before" => clm_review.src_failed_factcheck_before,
            "src_has_poor_writing_history" => clm_review.src_has_poor_writing_history,
            "src_supported_by_trolls" => clm_review.src_supported_by_trolls,
            "src_difficult_to_locate" => clm_review.src_difficult_to_locate,
            "src_other_problems" => clm_review.src_other_problems,
            "src_review_verdict" => clm_review.src_review_verdict,
            "src_review_description" => clm_review.src_review_description,
            "src_review_sharing_mode" => clm_review.src_review_sharing_mode,
            "src_review_is_completed" => clm_review.src_review_is_completed,
            "note_src_lacks_proper_credentials" => clm_review.note_src_lacks_proper_credentials,
            "note_src_failed_factcheck_before" => clm_review.note_src_failed_factcheck_before,
            "note_src_has_poor_writing_history" => clm_review.note_src_has_poor_writing_history,
            "note_src_supported_by_trolls" => clm_review.note_src_supported_by_trolls,
            "note_src_difficult_to_locate" => clm_review.note_src_difficult_to_locate,
            "note_src_other_problems" => clm_review.note_src_other_problems,
            "note_src_review_verdict" => clm_review.note_src_review_verdict,
            "note_src_review_description" => clm_review.note_src_review_description,
            "note_src_review_sharing_mode" => clm_review.note_src_review_sharing_mode
              }
          end
          src_json = {
            "name" => clm.name,
            "url" => clm.url,
            "url_preview" => clm.url_preview,
            "description" => clm.description,
            "src_type" => clm.src_type,
            "sharing_mode" => clm.sharing_mode,
            "src_review" => src_rev
          }
          result_json << src_json
          send_data result_json.to_json,
            :type => 'text/json; charset=UTF-8;',
            :disposition => "attachment; filename=src"+params[:id].to_s+".json"
      end
  end

  private

    def massport
      srcs_json=params[:srcs_json]
      send_data srcs_json,
        :type => 'text/json; charset=UTF-8;',
        :disposition => "attachment; filename=srcs.json"
    end

    def get_all_json
      @srcs_json = []
      @tmp.all.each do |clm|
        clm_json = {
          "name" => clm.name,
          "description" => clm.description,
          "url" => clm.url,
          "url_preview" => clm.url_preview,
          "src_type" => clm.src_type,
          "sharing_mode" => 1,
          "src_review" => src_rev
        }
        @srcs_json << clm_json
      end
      @srcs_json = @srcs_json.to_json
      @srcs_json=@srcs_json.to_s;
    end

    def src_params
      params.require(:src).permit(:name, :url, :src_type, :description, :sharing_mode, :url_preview, :start_review)
    end

    def find_src
      @src = Src.where("id=? AND (srcs.sharing_mode=1 OR srcs.user_id="+current_user.id.to_s+")",params[:id]).first
    end

    def define_types
      @all_src_types={"1"=>t('src_type_social_person'),"2"=>t('src_type_establishment'),"3"=>t('src_type_website'),"100"=>t('src_type_other'),"0"=>t('src_type_not_sure')}
      @src_types=[]
      @src_types.push(['Select',''])
      @all_src_types.each do |key, value|
        @src_types.push([value,key])
      end
    end

end
