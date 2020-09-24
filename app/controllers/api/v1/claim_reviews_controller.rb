module Api
  module V1
    class ClaimReviewsController < ApplicationController
      before_action :authenticate_user!
      before_action :find_claim, only: [:create, :edit, :new]
      respond_to :json

      def index
        condition=""
        if (current_user.role!="admin")
          condition="(blockchain_tx IS NULL OR blockchain_assessment_tx IS NOT NULL OR user_id="+current_user.id.to_s+") AND "
        end
        if (params[:by_claim].present?)
            qry=condition+" claim_id=? AND (review_sharing_mode=1 OR user_id=?)",params[:by_claim],current_user.id.to_s
            respond_with ClaimReview.where(qry)
        else
          qry=condition+" review_sharing_mode=1 OR user_id=?",current_user.id.to_s
          respond_with ClaimReview.where(qry)
        end
      end

      def show
        condition=""
        if (current_user.role!="admin")
          condition="(blockchain_tx IS NULL OR blockchain_assessment_tx IS NOT NULL OR user_id="+current_user.id.to_s+") AND "
        end
        if params[:by_claim].present?
          qry=condition+" claim_id=? AND (review_sharing_mode=1 OR user_id=?)",params[:id],current_user.id.to_s
        else
          qry=condition+" id=? AND (review_sharing_mode=1 OR user_id=?)",params[:id],current_user.id.to_s
        end
        respond_with ClaimReview.where(qry)
      end

      def update
        if (ENV['BLOCKCHAIN_ENABLED'] && params[:blockchain_assessment].present? && current_user.role=="admin")
          @tmp = ClaimReview.where("id=?",params[:id]).first
        else
          @tmp = ClaimReview.where("id=? AND user_id=?",params[:id],current_user.id).first
        end
        if (not @tmp.blank?)
          @claim_review=ClaimReview.find(@tmp.id)
          if (ENV['BLOCKCHAIN_ENABLED'] && params[:blockchain_assessment].present?)
            if (current_user.role=="admin")
              if (!@claim_review.blockchain_tx.blank?)
                output=save_to_the_blockchain_assessment()
                if (@save_to_blockchain=="-1")
                  render :json => { error:  output, claim_review_id: @claim_review.id, status: :expectation_failed }, status: :expectation_failed
                  return
                else
                  render :json => { ok:  output, claim_review_id: @claim_review.id, status: :ok }, status: :ok
                  return
                end
              else
                render :json => { error:  "The review is not found on the blockchain with ID ", claim_review_id: @claim_review.id, status: :bad_request }, status: :bad_request
                return
              end
            else
              render :json => { error:  "Only admins are allowed to assess claim reviews", status: :unauthorized }, status: :unauthorized
              return
            end
          end
          if (!@claim_review.blockchain_tx.blank?)
            render :json => { error:  "You cannot updated a claim review submitted to the blockchain", status: :locked }, status: :locked
            return
          elsif (params[:add_to_blockchain].present? || params[:time_added_to_blockchain].present? || params[:blockchain_tx].present? || params[:blockchain_id].present? || params[:blockchain_assessment].present? || params[:blockchain_assessment_tx].present? || params[:blockchain_assessment_time].present? || params[:blockchain_assessment_admin_id].present? || params[:blockchain_assessment_rationale].present?)
              render :json => { error:  "You cannot update blockchain-related fields", status: :ok }, status: :ok
              return
          else
            if (ClaimReview.update(params[:id], params[:claim_reviews]))
              render :json => { ok:  "Claim review updated successfully.", status: :ok }, status: :ok
              return
            else
              render :json => { error:  "Could not update the claim review", status: :expectation_failed }, status: :expectation_failed
              return
            end
          end
        else
          render :json => { error:  "There is no record of a claim review owned by you with that ID", status: :not_found }, status: :not_found
        end
      end

      def destroy
        @tmp = ClaimReview.where("id=? AND user_id=?",params[:id],current_user.id).first
        if (not @tmp.blank?)
          @claim_review=ClaimReview.find(@tmp.id)
          if (!@claim_review.blockchain_tx.blank?)
            render :json => { error:  "You cannot delete a claim review submitted to the blockchain", status: :locked }, status: :locked
            return
          else
            if (ClaimReview.destroy(params[:id]))
              render :json => { ok:  "Claim review deleted successfully.", status: :ok }, status: :ok
              return
            else
              render :json => { error:  "Could not delete the claim review", status: :expectation_failed }, status: :expectation_failed
              return
            end
          end
        else
          render :json => { error:  "There is no record of a claim review owned by you with that ID", status: :not_found }, status: :not_found
        end
      end

      def save_to_the_blockchain
          assessments={1=>"False",2=>"Mostly False",3=>"Mixed",4=>"Mostly True",5=>"True"}
          argmnt='{"Args":["addFactcheck","'+
          ENV['BLOCKCHAIN_ORGID']+'","'+
          @claim_review.id.to_s+'","'+
          current_user.id.to_s+'","'+
          @claim.blockchain_id.to_s+'", "'+
          assessments[@claim_review.review_verdict]+'","'+
          request.base_url+config.relative_url_root+'/claims'+@claim.id.to_s+'/claim_reviews/'+@claim_review.id.to_s+'","'+
          '1","5","'+
          @claim_review.review_verdict.to_s+'", "'+
          request.base_url+config.relative_url_root+'/assets/'+@claim_review.review_verdict.to_s+'.png'+'","'+
          @claim_review.img_review_started.to_s.gsub("''","")+'","'+
          @claim_review.img_old.to_s.gsub("''","")+'","'+
          @claim_review.img_forensic_discrepency.to_s.gsub("''","")+'","'+
          @claim_review.img_metadata_discrepency.to_s.gsub("''","")+'","'+
          @claim_review.img_logical_discrepency.to_s.gsub("''","")+'","'+
          escaped_str(@claim_review.note_img_old.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_img_forensic_discrepency.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_img_metadata_discrepency.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_img_logical_discrepency.to_s.gsub("''",""))+'","'+
          @claim_review.vid_review_started.to_s.gsub("''","")+'","'+
          @claim_review.vid_old.to_s.gsub("''","")+'","'+
          @claim_review.vid_forensic_discrepency.to_s.gsub("''","")+'","'+
          @claim_review.vid_metadata_discrepency.to_s.gsub("''","")+'","'+
          @claim_review.vid_audio_discrepency.to_s.gsub("''","")+'","'+
          @claim_review.vid_logical_discrepency.to_s.gsub("''","")+'","'+
          escaped_str(@claim_review.note_vid_old.to_s.gsub("''",""))+'","'+

          escaped_str(@claim_review.note_vid_forensic_discrepency.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_vid_metadata_discrepency.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_vid_audio_discrepency.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_vid_logical_discrepency.to_s.gsub("''",""))+'","'+
          @claim_review.txt_review_started.to_s.gsub("''","")+'","'+
          @claim_review.txt_unreliable_news_content.to_s.gsub("''","")+'","'+
          @claim_review.txt_insufficient_verifiable_srcs.to_s.gsub("''","")+'","'+
          @claim_review.txt_has_clickbait.to_s.gsub("''","")+'","'+
          @claim_review.txt_poor_language.to_s.gsub("''","")+'","'+
          @claim_review.txt_crowds_distance_discrepency.to_s.gsub("''","")+'","'+
          @claim_review.txt_author_offers_little_evidence.to_s.gsub("''","")+'","'+
          @claim_review.txt_reliable_sources_disapprove.to_s.gsub("''","")+'","'+
          escaped_str(@claim_review.note_txt_unreliable_news_content.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_txt_insufficient_verifiable_srcs.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_txt_has_clickbait.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_txt_poor_language.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_txt_crowds_distance_discrepency.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_txt_author_offers_little_evidence.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_txt_reliable_sources_disapprove.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.note_review_verdict.to_s.gsub("''",""))+'","'+
          escaped_str(@claim_review.review_description.to_s.gsub("''","")+' '+@claim_review.note_review_description.to_s.gsub("''",""))+
          '"]}'

#    puts ("\n=============Arguments:\n"+argmnt+"\n--\n")
          cmnd="peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile "+Rails.root.to_s+"/hyperledger/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles "+Rails.root.to_s+"/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles "+Rails.root.to_s+"/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '"+argmnt+"' --waitForEvent 2>&1"

#    puts ("\n=============Running:\n"+cmnd+"\n--\n")
          cmnd=Rails.root.to_s+"/hyperledger/fabric-samples/bin/"+cmnd
          output=%x(#{cmnd})
#    puts("Result:\n"+output+"\n==\n")
          begin
            tx_no=output.match(/ txid \[(.+?)\]/)[1]
            success_confirmation=output.match(/Chaincode invoke successful\. result\: status\:200 payload\:"(.+)"/)[1]
            if (success_confirmation.length>1)
              @save_to_blockchain=tx_no
              @claim_review.blockchain_id=output.match(/factcheckID.+?(F.+?)\\/)[1]
              @claim_review.add_to_blockchain="1"
              @claim_review.blockchain_tx=@save_to_blockchain
              @claim_review.time_added_to_blockchain=Time.now.utc.to_s[0...-7]
              @claim_review.save
            else
              @save_to_blockchain="-1"
            end
          rescue
              @save_to_blockchain="-1"
    #          @claim_review.destroy
          end
          return output
      end

      def save_to_the_blockchain_assessment
        if (params[:blockchain_assessment]=="1") then eval="approved" else eval="rejected" end

        argmnt='{"Args":["assessFactcheck","'+ENV['BLOCKCHAIN_ORGID']+'","'+@claim_review.blockchain_id.to_s+'", "'+current_user.id.to_s+'", "'+eval+'", "'+escaped_str(params[:blockchain_assessment_rationale].gsub('"', ''))+'"]}'
        cmnd="peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile "+Rails.root.to_s+"/hyperledger/fabric-samples/test-network/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n factcheck --peerAddresses localhost:7051 --tlsRootCertFiles "+Rails.root.to_s+"/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles "+Rails.root.to_s+"/hyperledger/fabric-samples/test-network/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '"+argmnt+"' --waitForEvent 2>&1"
#puts ("\n=============Running:\n"+cmnd+"\n--\n")
        cmnd=Rails.root.to_s+"/hyperledger/fabric-samples/bin/"+cmnd
        output=%x(#{cmnd})
#  puts("Result:\n"+output+"\n==\n")
        begin
          status_arr={"factchecks_open"=>1,"factchecks_received"=>2,"factchecks_settled"=>3}
          tx_no=output.match(/ txid \[(.+?)\]/)[1]
          success_confirmation=output.match(/Chaincode invoke successful\. result\: status\:200 payload\:"(.+)"/)[1]
          if (success_confirmation.length>1)
            @claim_review.blockchain_assessment=params[:blockchain_assessment].to_i
            @claim_review.blockchain_assessment_rationale=params[:blockchain_assessment_rationale]
            @claim_review.blockchain_assessment_admin_id=current_user.blockchain_id
            @claim_review.blockchain_assessment_time=Time.now.utc.to_s
            @save_to_blockchain=tx_no
            @claim_review.blockchain_assessment_tx=@save_to_blockchain
            if eval=="approved"
              @claim_review.review_sharing_mode="1"
            else
              @claim_review.review_sharing_mode="-1"
            end
            @claim_review.save
            if output.include? "All submitted factchecks have now been evaluated"
              @claim.status_on_blockchain=status_arr['factchecks_settled']
            else
              @claim.status_on_blockchain=status_arr['factchecks_received']
            end
byebug
            @claim.save

          else
            @save_to_blockchain="-1"
          end
        rescue
            @save_to_blockchain="-1"
        end
        return output
      end

      def create
#byebug
        @tmp = ClaimReview.where("claim_id=? AND user_id=?",@claim.id,current_user.id).first
        if (not @tmp.blank?)
          @claim_review=ClaimReview.find(@tmp.id)
          render :json => { error:  "You have already created a claim review for this claim", claim_review_id: @claim_review.id, status: :conflict }, status: :conflict
          return
        end
        if (!@claim.blockchain_tx.blank? && params[:add_to_blockchain]!=1)
          render :json => { error:  "Reviews of blockchain-based claims also need to be added to blockchain", status: :bad_request }, status: :bad_request
          return
        end
        @claim_review=current_user.claim_reviews.build(claim_review_params)
        if (@claim_review.save(validate: false))
          if (@claim_review.add_to_blockchain==1)
            if (@claim.blockchain_tx.blank? || @claim.status_on_blockchain==3)
              render :json => { error:  "Claim not accepting reviews on blockchain", status: :forbidden }, status: :forbidden
              @claim_review.destroy
              return
            end
            output=save_to_the_blockchain()
            if (@save_to_blockchain=="-1")
              render :json => { error:  output, status: :bad_request }, status: :bad_request
              @claim_review.destroy
            else
              render :json => { :response => "Created successfully and stored on blockchain: "+output, id: @claim_review.id.to_s, status: :created}, status: :created
            end
          else
            render :json => { :response => "Created successfully", id: @claim_review.id.to_s, status: :created}, status: :created
          end
        else
          render :json => { error:  "Unable to save claim", status: :expectation_failed }, status: :expectation_failed
        end
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

      def destroy
        claim_review=ClaimReview.where("id=? AND user_id=?",params[:id],current_user.id.to_s).first
        if (!claim_review)
          render :json => { error: "Unable to find claim review you created with id "+params[:id], status: :not_found }, status: :not_found
          return
        end
        if (!claim_review.blockchain_tx.nil?)
          render :json => { error:  "You cannot delete a blockchain-registered claim", status: :locked }, status: :locked
        else
          if (claim_review.destroy)
            render :json => { ok:  "Claim review deleted successfully", status: :ok }, status: :ok
          else
            render :json => { error:  "Unable to delete claim review", status: :expectation_failed }, status: :expectation_failed
          end
        end
      end

      def find_claim
        if Claim.exists?(:id => params[:claim_id])
          @claim=Claim.find(params[:claim_id]);
        else
          render :json => { error:  "Claim with id "+params[:claim_id].to_s+" does not exist!", status: :not_found }, status: :not_found
          return
        end
      end

      def claim_review_params
            params.require(:claim_review).permit(:id, :claim_id, :img_review_started, :img_old, :note_img_old, :img_forensic_discrepency, :note_img_forensic_discrepency, :img_metadata_discrepency, :note_img_metadata_discrepency, :img_logical_discrepency, :note_img_logical_discrepency, :vid_review_started, :vid_old, :note_vid_old, :vid_forensic_discrepency, :note_vid_forensic_discrepency, :vid_metadata_discrepency, :note_vid_metadata_discrepency, :vid_audio_discrepency, :note_vid_audio_discrepency, :vid_logical_discrepency, :note_vid_logical_discrepency, :txt_review_started, :txt_unreliable_news_content, :note_txt_unreliable_news_content, :txt_insufficient_verifiable_srcs, :note_txt_insufficient_verifiable_srcs, :txt_has_clickbait, :note_txt_has_clickbait, :txt_poor_language, :note_txt_poor_language, :txt_crowds_distance_discrepency, :note_txt_crowds_distance_discrepency, :txt_author_offers_little_evidence, :note_txt_author_offers_little_evidence, :txt_reliable_sources_disapprove, :note_txt_reliable_sources_disapprove, :review_verdict, :review_description, :note_review_description, :review_sharing_mode, :note_review_sharing_mode, :add_to_blockchain, :review_is_complete, :review_published_url, :note_review_verdict, :note_review_published_url)
      end

    private
      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end

    end
  end
end
