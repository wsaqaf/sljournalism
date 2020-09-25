module Api
  module V1
    class ClaimsController < ApplicationController
      before_action :authenticate_user!
      before_action :set_hyperledger_env
      respond_to :json

      def index
        qry=""
        reviewed="EXISTS (SELECT claim_id FROM claim_reviews WHERE claims.id=claim_reviews.claim_id AND claim_reviews.review_sharing_mode=1 AND claim_reviews.review_verdict IS NOT NULL AND (blockchain_tx IS NULL OR blockchain_assessment_tx IS NOT NULL))"
        if (params[:type]=="blockchain_only")
          qry="blockchain_tx IS NOT NULL AND "+qry;
        elsif (params[:type]=="regular_only")
          qry="blockchain_tx IS NULL AND "+qry;
        end
        if (params[:status]=="reviewed")
          qry=reviewed+" AND "+qry
        elsif (params[:status]=="pending")
          qry=" NOT "+reviewed+" AND "+qry
        end
        respond_with Claim.where(qry+"(sharing_mode=1 OR user_id=?)",current_user.id.to_s).order(Arel.sql("updated_at DESC"))
      end

      def show
          respond_with Claim.where("id=? AND (sharing_mode=1 OR user_id=?)",params[:id],current_user.id.to_s)
      end

      def create
        if !params[:url].empty?
          claim=Claim.where("title=? AND url=? AND user_id=?",params[:title],params[:url],current_user.id.to_s).first
          if (claim)
            render :json => { error:  "You have already submitted a claim with the same title and URL", id: claim.id, status: :conflict }, status: :conflict
            return
          end
          params[:url]=get_preview([:url])
        end
        @claim=current_user.claims.build(allowed_params)
        if (@claim.save)
          if (@claim.add_to_blockchain==1)
            output=save_to_the_blockchain()
            if (@save_to_blockchain=="-1")
              render :json => { error:  output, status: :bad_request }, status: :bad_request
            else
              render :json => { :response => "Created successfully and stored on blockchain: "+output, id: @claim.id.to_s, status: :created}, status: :created
            end
          else
            render :json => { :response => "Created successfully", id: @claim.id.to_s, status: :created}, status: :created
          end
        else
          render :json => { error:  "Unable to save claim", status: :expectation_failed }, status: :expectation_failed
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

#    puts ("\n=============Running:\n"+cmnd+"\n--\n")
          cmnd=Rails.root.to_s+"/hyperledger/fabric-samples/bin/"+cmnd
          output=%x(#{cmnd})
    #puts("Result:\n"+output+"\n==\n")
          begin
            status_arr={"factchecks_open"=>1,"factchecks_received"=>2,"factchecks_settled"=>3}
            tx_no=output.match(/ txid \[(.+?)\]/)[1]
            success_confirmation=output.match(/Chaincode invoke successful\. result\: status\:200 payload\:"(.+)"/)[1]
            if (success_confirmation.length>1)
              @claim.blockchain_id=output.match(/claimID.+?(C.+?)\\/)[1]
              @save_to_blockchain=tx_no
              @claim.add_to_blockchain=1
              @claim.status_on_blockchain=status_arr['factchecks_open']
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

      def update
        claim=Claim.where("id=? AND user_id=?",params[:id],current_user.id.to_s).first
        if (!claim)
          render :json => { error:  "Unable to find claim with id "+params[:id]+" created by user id "+current_user.id.to_s, status: :not_found }, status: :not_found
          return
        end
        if (!claim.blockchain_tx.nil?)
          render :json => { error:  "You cannot update a blockchain-registered claim", status: :locked }, status: :locked
        else
          if (Claim.update(params[:id], allowed_params))
            render :json => { ok:  "Claim updated successfully", status: :ok }, status: :ok
          else
            render :json => { error:  "Unable to update claim", status: :expectation_failed }, status: :expectation_failed
          end
        end
      end

      def destroy
        claim=Claim.where("id=? AND user_id=?",params[:id],current_user.id.to_s).first
        if (!claim)
          render :json => { error: "Unable to find claim with id "+params[:id]+" created by user id "+current_user.id.to_s, status: :not_found }, status: :not_found
          return
        end
        if (!claim.blockchain_tx.nil?)
          render :json => { error:  "You cannot delete a blockchain-registered claim", status: :locked }, status: :locked
        else
          ClaimReview.where("claim_id = ?",claim.id).destroy_all
          Tagging.where("claim_id = ?",claim.id).destroy_all
          Tag.where.not(id: Tagging.pluck(:tag_id).reject {|x| x.nil?}).destroy_all
          if (claim.destroy)
            render :json => { ok:  "Claim deleted successfully", status: :ok }, status: :ok
          else
            render :json => { error:  "Unable to delete claim", status: :expectation_failed }, status: :expectation_failed
          end
        end
      end

      def allowed_params
          params.require(:claim).permit(:title, :has_image, :has_video, :has_text, :description, :url, :url_preview, :sharing_mode, :add_to_blockchain, :expiry_date, :reward_amount, :conditions)
      end

    end
  end
end
