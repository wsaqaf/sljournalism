class ClaimsController < ApplicationController
  before_action :check_if_signed_in, only: [:show, :edit, :update, :destroy, :new, :create]
  before_action :find_claim, only: [:show, :edit, :update, :destroy]
  before_action :blockchain_check1, only: [:new, :create]
  before_action :blockchain_check2, only: [:edit, :update, :destroy]

  def blockchain_check1
    if (current_user.role!="client" && ENV['BLOCKCHAIN_ENABLED'])
      redirect_to claims_path
    end
  end

  def blockchain_check2
    unless ENV['BLOCKCHAIN_ENABLED']
      redirect_to claims_path
    end
  end

  def on_blockchain2
    unless ENV['BLOCKCHAIN_ENABLED']
      redirect_to claims_path
    end
  end

  def index
    if params[:import_note].present?
      @import_note=params[:import_note]
    else
      @import_note=""
    end
    if (params[:sort].present?)
      @sort_msg=sort_bar("Claims",params[:sort])
    else
      @sort_msg=sort_bar("Claims","td")
    end
    if (params[:filter]=="r")
      qry="claims.id in (SELECT claim_id FROM claim_reviews WHERE (claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s+") AND claim_reviews.review_sharing_mode=1 AND review_verdict IS NOT NULL)"
      @filter_msg=filter_bar("Claims","r")
    elsif (params[:filter]=="m")
      qry="claims.user_id="+current_user.id.to_s
      @filter_msg=filter_bar("Claims","m")
    elsif (params[:filter]=="u")
      qry="claims.id in (SELECT claim_id FROM claim_reviews WHERE claim_reviews.user_id="+current_user.id.to_s+")"
      @filter_msg=filter_bar("Claims","u")
    elsif (params[:filter]=="n")
      qry="(claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s+") AND NOT EXISTS (SELECT claim_id FROM claim_reviews WHERE claims.id=claim_reviews.claim_id AND ((claim_reviews.review_sharing_mode=1 AND claim_reviews.review_verdict IS NOT NULL) OR claim_reviews.user_id="+current_user.id.to_s+"))"
      @filter_msg=filter_bar("Claims","n")
    elsif (params[:q].present?)
      @filter_msg=filter_bar("Claims","a")
      qry=" (claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s+") and (lower(title) like lower('%"+params[:q]+"%') or lower(description) like lower('%"+params[:q]+"%') or lower(url_preview) like lower('%"+params[:q]+"%'))"
    elsif (params[:m].present?)
      @filter_msg=filter_bar("Claims","a")
      qry=" (claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s+") and medium_id="+params[:m].to_s
    elsif (params[:s].present?)
      @filter_msg=filter_bar("Claims","a")
      qry=" (claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s+") and src_id="+params[:s].to_s
    elsif(params[:tag_list].present?)
        output=''
        added=0
        tag_list=params[:tag_list].split(/\s*,\s*/)
        for tag_name in tag_list
            tag=Tag.where("claim_name=?",tag_name).first
            if (tag.nil?) then
                result=Tag.create(claim_name: tag_name);
                if (!result.valid?)
                   output=output+"- "+t('tag_could_not_add')+tag_name+"!<br>"
                else
                   output=output+"- "+tag_name+t('tag_added')+"<br>"
                   added=1
                end
            else
                output=output+"- "+tag_name+t('tag_exists')+"<br>"
                added=1
            end
        end
        if (added==1)
            lst="var result2 = \""+output+"\";";
            output=output+"<br>"+t('tags_added')+"\n<script>\n"+lst+"\n</script>"
        end
        render json: output;
    elsif (params[:refresh_tag_list].present?)
      output=''
      Tag.order(Arel.sql('lower(claim_name) ASC')).each do |t|
          output=output+'<option value="'+t.id.to_s+'">'+t.claim_name+"</option>\n"
      end
      render json: output;
    elsif (params[:url].present?)
        output=get_preview(params[:url])
        render json: output;
        return
    else
        @filter_msg=filter_bar("Claims","a")
        if params[:tag]
          tmp=Claim.tagged_with(params[:tag])
          @total_count=tmp.count
        elsif (params[:sort]=="r" or params[:sort]=="rp" or params[:sort]=="rn")
          remove_unsure="";
          if (params[:sort]!="r")
            remove_unsure=" AND claim_reviews.review_verdict!=0 "
          end
          tmp=Claim.joins(:claim_reviews).where("claims.id=claim_reviews.claim_id and (claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s+") and claim_reviews.review_sharing_mode=1 and claim_reviews.review_verdict IS NOT NULL"+remove_unsure).group("claims.id").order(Arel.sql(sort_statement("claim",params[:sort])))
          @total_count=tmp.count.length
        elsif  (params[:sort]=="rt")
          tmp=Claim.joins(:claim_reviews).where("claims.id=claim_reviews.claim_id and (claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s+") and claim_reviews.review_sharing_mode=1 and claim_reviews.review_verdict IS NOT NULL").group("claims.id,claim_reviews.updated_at,claim_reviews.created_at").order(Arel.sql(sort_statement("claim",params[:sort])))
          @total_count=tmp.count.length
        elsif !user_signed_in?
            return
        else
          if qry.nil? then qry="claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s; end
          tmp=Claim.where(qry).order(Arel.sql("created_at DESC"))
          @total_count=tmp.count
        end
        @pagy, @claims = pagy(tmp, items: 10)
        return
    end
    if params[:tag]
        tmp=Claim.tagged_with(params[:tag])
        @total_count=tmp.count
    elsif (params[:sort]=="r" or params[:sort]=="rp" or params[:sort]=="rn")
        remove_unsure="";
        if (params[:sort]!="r")
          remove_unsure=" AND src_reviews.src_review_verdict!=0 "
        end
        tmp=Claim.joins(:claim_reviews).where("claims.id=claim_reviews.claim_id and (claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s+") and claim_reviews.review_sharing_mode=1 and claim_reviews.review_verdict IS NOT NULL"+remove_unsure).group("claims.id").order(Arel.sql(sort_statement("claim",params[:sort])))
        @total_count=tmp.count.length
    elsif  (params[:sort]=="rt")
        tmp=Claim.joins(:claim_reviews).where("claims.id=claim_reviews.claim_id and (claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s+") and claim_reviews.review_sharing_mode=1 and claim_reviews.review_verdict IS NOT NULL").group("claims.id,claim_reviews.updated_at,claim_reviews.created_at").order(Arel.sql(sort_statement("claim",params[:sort])))
        @total_count=tmp.count.length
    elsif !user_signed_in?
          return
    else
        if qry.nil? then qry="claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s; end
        tmp=Claim.where(qry).order(Arel.sql("created_at DESC"))
    end
    @total_count=tmp.count
    @pagy, @claims = pagy(tmp, items: 10)
  end

  def show
    @warning_msg=""
    dependent_reviews=ClaimReview.where("claim_id = ?",@claim.id).count("id")
    if (dependent_reviews>0)
      @warning_msg= t('warning_del_dependents', count:dependent_reviews.to_s)+".\n"
    end
    @warning_msg=@warning_msg+"\n"+t('warning_del')
  end

  def new
    if (!ENV['BLOCKCHAIN_ENABLED'] || current_user.role=="client")
      @claim = current_user.claims.build
      @srcs = Src.all.map{ |c| [c.name, c.id]}
      @media = Medium.all.map{ |m| [m.name, m.id]}
    else
      redirect_to claims_path
    end
  end

  def save_to_the_blockchain
      medium=""
      src=""
      if (@claim.medium_id) then medium=Medium.find(@claim.medium_id).name end
      if (@claim.src_id) then src=Src.find(@claim.src_id).name end
      argmnt='{"Args":["addClaim","'+
      ENV['BLOCKCHAIN_ORGID']+'","'+
      @claim.id.to_s+'","'+
      current_user.id.to_s+'", "'+
      escaped_str(@claim.title.to_s.gsub("''",""))+'","'+
      request.base_url+config.relative_url_root+"/claims"+escaped_str(@claim.id.to_s.gsub("''",""))+'","'+
      @claim.expiry_date.to_s[0...-7].gsub("''","")+'","'+
      @claim.reward_amount.to_s.gsub("''","")+'","'+
      escaped_str(@claim.conditions.to_s.gsub("''",""))+'","'+
      @claim.url.gsub("''","")+'","'+
      escaped_str(@claim.description.to_s.gsub("''",""))+'","'+
      medium.gsub("''","")+'","'+
      src.gsub("''","")+'","'+
      @claim.has_image.to_s+'","'+
      @claim.has_video.to_s+'","'+
      @claim.has_text.to_s+'","'+
      @claim.tags.map(&:claim_name).join(', ').gsub("''","")+'"]}'

      cmnd="peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile "+Rails.root.to_s+"/hyperledger/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles "+Rails.root.to_s+"/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles "+Rails.root.to_s+"/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '"+argmnt+"' --waitForEvent 2>&1"

puts ("\n=============Running:\n"+cmnd+"\n--\n")
      output=%x(#{cmnd})
#puts("Result:\n"+output+"\n==\n")
      begin
        tx_no=output.match(/ txid \[(.+?)\]/)[1]
        success_confirmation=output.match(/Chaincode invoke successful\. result\: status\:200 payload\:"(.+)"/)[1]
        if (success_confirmation.length>1)
          @claim.blockchain_id=output.match(/claimID.+?(C.+?)\\/)[1]
          @save_to_blockchain=tx_no
          @claim.add_to_blockchain=1
          @claim.blockchain_tx=@save_to_blockchain
          @claim.time_added_to_blockchain=Time.now.utc.to_s[0...-7]
          @claim.save
        else
          @save_to_blockchain="-1"
        end
      rescue
          @save_to_blockchain="-1"
          @claim.destroy
      end
      return output
  end

  def create
#byebug
    start_review=0
    if (!params[:claim].nil?)
      start_review=params[:claim][:start_review]
      params[:claim].delete(:start_review)
    end
    @import_note=""
    if (params[:claims_json].present?)
      massport
    elsif (!params[:claim].nil? && ((!params[:claim][:url].empty? && params[:claim][:include_review].present?) || params[:claim][:file]))
      if (params[:claim][:include_review].present?)
        if (params[:claim][:file].present?)
          myfile=params[:claim][:file]
          file_contents=myfile.read
        else
          myfile=params[:claim][:url]
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
            claim_list = JSON.parse(file_contents)
            claim_list.each do |clm|
              @claim = Claim.where("title= ?",clm['title']).first
              if (!@claim.nil?)
                if (params[:claim][:overwrite]=="1" && @claim.user_id==current_user.id)
                  if (params[:claim][:include_review]=="1" && !clm['claim_review'].blank?)
                    @claim_review = ClaimReview.where("claim_id=? AND user_id=?",@claim.id,current_user.id).first
                    if (not @claim_review.blank?)
                      @claim_review=ClaimReview.find(@claim_review.id)
                      @claim_review.update(clm['claim_review'])
                      @import_note=@import_note+t('claim_review_imported')+"<br>"
                    else
                      current_user.claim_reviews.build(clm['claim_review'])
                    end
                  else
                    clm.delete('claim_review')
                    if (@claim.update(clm))
                       @import_note=@import_note+t('claim_imported')+"<br>"
                    else
                       @import_note=@import_note+t('claim_not_imported')+"<br>"
                    end
                  end
                else
                  @import_note=@import_note+t('claim_not_imported')+"<br>"
                end
              else
                c_rev=clm['claim_review']
                clm.delete('claim_review')
                @claim = current_user.claims.build(clm)
                if @claim.save
                  @import_note=@import_note+t('claim_imported')+"<br>"
                  if (!c_rev.blank?)
                    c_rev["claim_id"]= { "claim_id" => @claim.id }
                    @claim_review = ClaimReview.new
                    @claim_review.claim_id=@claim.id
                    @claim_review.user_id=current_user.id

                    @claim_review.img_review_started= c_rev["img_review_started"]
                    @claim_review.img_old= c_rev["img_old"]
                    @claim_review.img_forensic_discrepency= c_rev["img_forensic_discrepency"]
                    @claim_review.img_metadata_discrepency= c_rev["img_metadata_discrepency"]
                    @claim_review.img_logical_discrepency= c_rev["img_logical_discrepency"]
                    @claim_review.note_img_old= c_rev["note_img_old"]
                    @claim_review.note_img_forensic_discrepency= c_rev["note_img_forensic_discrepency"]
                    @claim_review.note_img_metadata_discrepency= c_rev["note_img_metadata_discrepency"]
                    @claim_review.note_img_logical_discrepency= c_rev["note_img_logical_discrepency"]
                    @claim_review.vid_review_started= c_rev["vid_review_started"]
                    @claim_review.vid_old= c_rev["vid_old"]
                    @claim_review.vid_forensic_discrepency= c_rev["vid_forensic_discrepency"]
                    @claim_review.vid_metadata_discrepency= c_rev["vid_metadata_discrepency"]
                    @claim_review.vid_audio_discrepency= c_rev["vid_audio_discrepency"]
                    @claim_review.vid_logical_discrepency= c_rev["vid_logical_discrepency"]
                    @claim_review.note_vid_old= c_rev["note_vid_old"]
                    @claim_review.note_vid_forensic_discrepency= c_rev["note_vid_forensic_discrepency"]
                    @claim_review.note_vid_metadata_discrepency= c_rev["note_vid_metadata_discrepency"]
                    @claim_review.note_vid_audio_discrepency= c_rev["note_vid_audio_discrepency"]
                    @claim_review.note_vid_logical_discrepency= c_rev["note_vid_logical_discrepency"]
                    @claim_review.txt_review_started= c_rev["txt_review_started"]
                    @claim_review.txt_unreliable_news_content= c_rev["txt_unreliable_news_content"]
                    @claim_review.txt_insufficient_verifiable_srcs= c_rev["txt_insufficient_verifiable_srcs"]
                    @claim_review.txt_has_clickbait= c_rev["txt_has_clickbait"]
                    @claim_review.txt_poor_language= c_rev["txt_poor_language"]
                    @claim_review.txt_crowds_distance_discrepency= c_rev["txt_crowds_distance_discrepency"]
                    @claim_review.txt_author_offers_little_evidence= c_rev["txt_author_offers_little_evidence"]
                    @claim_review.txt_reliable_sources_disapprove= c_rev["txt_reliable_sources_disapprove"]
                    @claim_review.note_txt_unreliable_news_content= c_rev["note_txt_unreliable_news_content"]
                    @claim_review.note_txt_insufficient_verifiable_srcs= c_rev["note_txt_insufficient_verifiable_srcs"]
                    @claim_review.note_txt_has_clickbait= c_rev["note_txt_has_clickbait"]
                    @claim_review.note_txt_poor_language= c_rev["note_txt_poor_language"]
                    @claim_review.note_txt_crowds_distance_discrepency= c_rev["note_txt_crowds_distance_discrepency"]
                    @claim_review.note_txt_author_offers_little_evidence= c_rev["note_txt_author_offers_little_evidence"]
                    @claim_review.note_txt_reliable_sources_disapprove= c_rev["note_txt_reliable_sources_disapprove"]
                    @claim_review.review_verdict= c_rev["review_verdict"]
                    @claim_review.note_review_verdict= c_rev["note_review_verdict"]
                    @claim_review.review_sharing_mode= c_rev["review_sharing_mode"]

                    if (@claim_review.save)
                      @import_note=@import_note+t('claim_review_imported')+"<br>"
                    else
                      @import_note=@import_note+t('claim_review_not_imported')+"<br>"
                    end
                  end
                else
                  @import_note=@import_note+t('claim_not_imported')+"<br>"
                end
              end
            end
           rescue
             redirect_to new_claim_path(:import_err => 1)
             return
           end
         end
         render 'show'
        end
      else
        @claim = current_user.claims.build(claim_params)
        if @claim.save
            if start_review=="1"
              @claim_review = ClaimReview.new
              @claim_review.claim_id=@claim.id
              @claim_review.user_id=current_user.id
              @claim_review.save(validate: false)
              redirect_to claim_claim_review_step_path(@claim,@claim_review, ClaimReview.form_steps.first)
            else
              redirect_to claims_path
            end
        else
            render 'new'
        end
      end
    else
      if (claim_params['add_to_blockchain'] && ENV['BLOCKCHAIN_ENABLED'] && current_user.role=="client")
          @claim = current_user.claims.build(claim_params)
          if (@claim.save)
            output=save_to_the_blockchain()
            if (@save_to_blockchain=="-1")
              redirect_to new_claim_path(:blockchain_resp => @save_to_blockchain, :error => output)
            else
              redirect_to claims_path(:blockchain_resp => @save_to_blockchain, :response => output)
            end
          end
          return
      end
      @claim = current_user.claims.build(claim_params)
      if @claim.save
        if start_review==1
          @claim_review = ClaimReview.new
          @claim_review.claim_id=@claim.id
          @claim_review.user_id=current_user.id
          @claim_review.save(validate: false)
          redirect_to claim_claim_review_step_path(@claim,@claim_review, ClaimReview.form_steps.first)
        else
          redirect_to claims_path
        end
      else
          render 'new'
      end
    end
  end

  def edit
    if current_user.id!=@claim.user_id && current_user.role!="admin"
      redirect_to claim_path(@claim)
    end
  end

  def update
    if current_user.id!=@claim.user_id && current_user.role!="admin"
      redirect_to claim_path(@claim)
      return
    end
    if @claim.update(claim_params)
      redirect_to claim_path(@claim)
    else
      render 'edit'
    end
  end

  def destroy
    ClaimReview.where("claim_id = ?",@claim.id).destroy_all
    Tagging.where("claim_id = ?",@claim.id).destroy_all
    Tag.where.not(id: Tagging.pluck(:tag_id).reject {|x| x.nil?}).destroy_all
    @claim.destroy
    redirect_to claims_path
  end

  def export
      if (!params[:id].blank?)
          clm=Claim.find(params[:id])
          result_json=[]
          claim_rev={}
          clm_review = ClaimReview.where("claim_id=? AND review_sharing_mode=1",clm.id).first
          if (!clm_review.blank?)
            claim_rev={
                "img_review_started" => clm_review.img_review_started,
                "img_old" => clm_review.img_old,
                "img_forensic_discrepency" => clm_review.img_forensic_discrepency,
                "img_metadata_discrepency" => clm_review.img_metadata_discrepency,
                "img_logical_discrepency" => clm_review.img_logical_discrepency,
                "note_img_old" => clm_review.note_img_old,
                "note_img_forensic_discrepency" => clm_review.note_img_forensic_discrepency,
                "note_img_metadata_discrepency" => clm_review.note_img_metadata_discrepency,
                "note_img_logical_discrepency" => clm_review.note_img_logical_discrepency,
                "vid_review_started" => clm_review.vid_review_started,
                "vid_old" => clm_review.vid_old,
                "vid_forensic_discrepency" => clm_review.vid_forensic_discrepency,
                "vid_metadata_discrepency" => clm_review.vid_metadata_discrepency,
                "vid_audio_discrepency" => clm_review.vid_audio_discrepency,
                "vid_logical_discrepency" => clm_review.vid_logical_discrepency,
                "note_vid_old" => clm_review.note_vid_old,
                "note_vid_forensic_discrepency" => clm_review.note_vid_forensic_discrepency,
                "note_vid_metadata_discrepency" => clm_review.note_vid_metadata_discrepency,
                "note_vid_audio_discrepency" => clm_review.note_vid_audio_discrepency,
                "note_vid_logical_discrepency" => clm_review.note_vid_logical_discrepency,
                "txt_review_started" => clm_review.txt_review_started,
                "txt_unreliable_news_content" => clm_review.txt_unreliable_news_content,
                "txt_insufficient_verifiable_srcs" => clm_review.txt_insufficient_verifiable_srcs,
                "txt_has_clickbait" => clm_review.txt_has_clickbait,
                "txt_poor_language" => clm_review.txt_poor_language,
                "txt_crowds_distance_discrepency" => clm_review.txt_crowds_distance_discrepency,
                "txt_author_offers_little_evidence" => clm_review.txt_author_offers_little_evidence,
                "txt_reliable_sources_disapprove" => clm_review.txt_reliable_sources_disapprove,
                "note_txt_unreliable_news_content" => clm_review.note_txt_unreliable_news_content,
                "note_txt_insufficient_verifiable_srcs" => clm_review.note_txt_insufficient_verifiable_srcs,
                "note_txt_has_clickbait" => clm_review.note_txt_has_clickbait,
                "note_txt_poor_language" => clm_review.note_txt_poor_language,
                "note_txt_crowds_distance_discrepency" => clm_review.note_txt_crowds_distance_discrepency,
                "note_txt_author_offers_little_evidence" => clm_review.note_txt_author_offers_little_evidence,
                "note_txt_reliable_sources_disapprove" => clm_review.note_txt_reliable_sources_disapprove,
                "review_verdict" => clm_review.review_verdict,
                "note_review_verdict" => clm_review.note_review_verdict,
                "review_sharing_mode" => clm_review.review_sharing_mode
              }
          end
          claim_json = {
            "title" => clm.title,
            "url" => clm.url,
            "url_preview" => clm.url_preview,
            "description" => clm.description,
            "has_image" => clm.has_image,
            "has_video" => clm.has_video,
            "has_text" => clm.has_text,
            "sharing_mode" => clm.sharing_mode,
            "claim_review" => claim_rev
          }
          result_json << claim_json
          send_data result_json.to_json,
            :type => 'text/json; charset=UTF-8;',
            :disposition => "attachment; filename=claim"+params[:id].to_s+".json"
      end
  end

  private

    def is_img(url)
      require 'open-uri'
      str = open(url)
      if str.content_type.to_s.include? "image" or str.content_type.to_s.include? "img"
        return true
      end
      return false
    end

    def massport
      claims_json=params[:claims_json]
      send_data claims_json,
        :type => 'text/json; charset=UTF-8;',
        :disposition => "attachment; filename=claims.json"
    end

    def get_all_json
      @claims_json = []
      @tmp.all.each do |clm|
        clm_json = {
          "title" => clm.title,
          "description" => clm.description,
          "url" => clm.url,
          "url_preview" => clm.url_preview,
          "has_image" => clm.has_image,
          "has_video" => clm.has_video,
          "has_text" => clm.has_text,
          "sharing_mode" => 1,
          "claim_review" => claim_rev
        }
        @claims_json << clm_json
      end
      @claims_json = @claims_json.to_json
      @claims_json=@claims_json.to_s;
    end

    def claim_params
      if (!params[:overwrite].present?)
        params.require(:claim).permit(:id, :title, :medium_name, :src_name, :url, :description, :has_image, :has_video, :has_text, :sharing_mode, :url_preview, :tag_list, :tag, { tag_ids: [] }, :tag_ids, :start_review, :add_to_blockchain, :expiry_date, :reward_amount, :conditions)
#      else
#        params.require(:claim).permit(:id, :title, :medium_name, :src_name, :url, :description, :has_image, :has_video, :has_text, :sharing_mode, :url_preview, :tag_list, :tag, { tag_ids: [] }, :tag_ids, :file, :include_review, :overwrite)
      end
    end

    def find_claim
        @claim = Claim.where("id=? AND (claims.sharing_mode=1 OR claims.user_id="+current_user.id.to_s+")",params[:id]).first
    end
end
