class ClaimReviewsController < ApplicationController
  before_action :find_claim
  before_action :check_if_signed_in
  before_action :blockchain_check1, only: [:new, :create]
  before_action :blockchain_check2, only: [:update, :edit, :destroy]

  def blockchain_check1
    if (current_user.role!="factchecker" && ENV['BLOCKCHAIN_ENABLED'])
      redirect_to claims_path
    end
  end

  def blockchain_check2
    if (ENV['BLOCKCHAIN_ENABLED'])
      redirect_to claims_path
    end
  end

  def index
    if current_user.role=="admin"
      @claim_reviews = ClaimReview.all.order(Arel.sql("created_at DESC")).where("claim_id=? AND ((review_verdict IS NOT NULL) OR user_id=?)",@claim.id,current_user.id)
    else
      @claim_reviews = ClaimReview.all.order(Arel.sql("created_at DESC")).where("claim_id=? AND ((review_sharing_mode=1 AND review_verdict IS NOT NULL) OR user_id=?)",@claim.id,current_user.id)
    end
  end

  def show
    if current_user.role=="admin"
      @tmp = ClaimReview.where("id=?",params[:id]).first
    else
      @tmp = ClaimReview.where("id=? AND (review_sharing_mode=1 OR user_id=?)",params[:id],current_user.id).first
    end
    if (not @tmp.blank?)
      @claim_review=ClaimReview.find(@tmp.id)
    else
      redirect_to claims_path
    end
    if (ENV['BLOCKCHAIN_ENABLED'] && params[:blockchain_assessment].present? && current_user.role=="admin")
      output=save_to_the_blockchain()
      if (@save_to_blockchain=="-1")
        output="<h4>Error:</h4><font color=red>"+output+"</font>"
      else
        output="<h4>Assessment successful!</h4><font color=green>"+output+"</font>"
      end
      render json: output
    end
  end

  def save_to_the_blockchain
        if (params[:blockchain_assessment]=="1") then eval="approved" else eval="rejected" end

        argmnt='{"Args":["assessFactcheck","'+ENV['BLOCKCHAIN_ORGID']+'","'+@claim_review.blockchain_id.to_s+'", "'+current_user.id.to_s+'", "'+eval+'", "'+escaped_str(params[:blockchain_assessment_rationale].gsub('"', ''))+'"]}'
        cmnd="peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile "+Rails.root.to_s+config.relative_url_root+"/hyperledger/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles "+Rails.root.to_s+config.relative_url_root+"/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles "+Rails.root.to_s+config.relative_url_root+"/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '"+argmnt+"' --waitForEvent 2>&1"

puts ("\n=============Running:\n"+cmnd+"\n--\n")
        cmnd=Rails.root.to_s+"/hyperledger/fabric-samples/bin/"+cmnd
        output=%x(#{cmnd})
#  puts("Result:\n"+output+"\n==\n")
        begin
          tx_no=output.match(/ txid \[(.+?)\]/)[1]
          success_confirmation=output.match(/Chaincode invoke successful\. result\: status\:200 payload\:"(.+)"/)[1]
          if (success_confirmation.length>1)
            @claim_review.blockchain_assessment=params[:blockchain_assessment].to_i
            @claim_review.blockchain_assessment_rationale=params[:blockchain_assessment_rationale]
            @claim_review.blockchain_assessment_admin_id=current_user.blockchain_id
            @claim_review.blockchain_assessment_time=Time.now.utc.to_s
            @save_to_blockchain=tx_no
            @claim_review.blockchain_tx=@save_to_blockchain
            @claim_review.save
            if output.include? "Claim successfully factchecked and rewards (if any) settled"
              @claim.status_on_blockchain="Finished and no longer accepts reviews."
            else
              @claim.status_on_blockchain="Received at least one review, open for more."
            end
            @claim.save

          else
            @save_to_blockchain="-1"
          end
        rescue
            @save_to_blockchain="-1"
        end
        return output
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
