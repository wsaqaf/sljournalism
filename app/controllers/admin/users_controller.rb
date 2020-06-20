class Admin::UsersController < Admin::BaseController

  def index
    @users = User.all.order(Arel.sql("updated_at DESC"))
  end

  def edit
    unless @user = User.where(id: params[:id]).first
      redirect_to admin_users_path
    end
#redirect_to edit_admin_user_path(@user.id)
  end

  def create
    @user = User.create(user_create_params)
    if @user.save
      if (ENV['BLOCKCHAIN_ENABLED'])
        argmnt="{\"Args\":[\"registerWallet\",\""+@user.role+"\",\""+ENV['BLOCKCHAIN_ORGID']+"\",\""+@user.id.to_s+"\", \""+@user.name+"\"]}"
        cmnd="docker exec -it cli peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '"+argmnt+"' --waitForEvent"
#puts ("\n=============\nRunning:\n"+cmnd+"\n--\n")
        output=%x(#{cmnd})
#puts("Result:\n"+output+"\n==\n")
        begin
          tx_no=output.match(/ txid \[(.+?)\]/)[1]
          success_confirmation=output.match(/Chaincode invoke successful\. result\: status\:200 payload\:"(.+)"/)[1]
          if (success_confirmation.length>1)
            @save_to_blockchain=tx_no
            @user.add_to_blockchain=1
            @user.blockchain_tx=@save_to_blockchain
            @user.time_added_to_blockchain=Time.now.utc.to_s
            @user.save
          else
            @save_to_blockchain="-1"
          end
        rescue
            @save_to_blockchain="-1"
            @user.destroy
        end
        redirect_to admin_users_path(:blockchain_resp => @save_to_blockchain, :error => output)
      else
        redirect_to admin_users_path
      end
    else
        render 'new'
    end
  end

  def new
    @user = User.new
  end


  def update
    unless @user = User.where(id: params[:id]).first
      redirect_to admin_users_path
      return
    end
    if @user.update(user_params)

      redirect_to admin_users_path
    else
      render 'edit'
    end
  end


  def show
    if (ENV['BLOCKCHAIN_ENABLED'] && params[:add_to_blockchain])
      if (@user = User.where(id: params[:id]).first)
          argmnt="{\"Args\":[\"registerWallet\",\""+@user.role+"\",\""+ENV['BLOCKCHAIN_ORGID']+"\",\""+@user.id.to_s+"\", \""+@user.name+"\"]}"
          cmnd="docker exec -it cli peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '"+argmnt+"' --waitForEvent"
#puts ("\n=============\nRunning:\n"+cmnd+"\n--\n")
          output=%x(#{cmnd})
#puts("Result:\n"+output+"\n==\n")
          begin
            tx_no=output.match(/ txid \[(.+?)\]/)[1]
            success_confirmation=output.match(/Chaincode invoke successful\. result\: status\:200 payload\:"(.+)"/)[1]
            if (success_confirmation.length>1)
              @save_to_blockchain=tx_no
              @user.add_to_blockchain=1
              @user.blockchain_tx=@save_to_blockchain
              @user.time_added_to_blockchain=Time.now.utc.to_s
              @user.save
            else
              @save_to_blockchain="-1"
            end
          rescue
              @save_to_blockchain="-1"
          end
          if (@save_to_blockchain=="-1")
            output="<font color=red>"+output+"</font>"
          else
            output="<font color=green>"+output+"</font>"
          end
          render json: output
          return
      end
      redirect_to admin_users_path
      return
    end
    if (ENV['BLOCKCHAIN_ENABLED'] && (params[:getbalance].present? || params[:addtobalance].present?))
      argmnt='{"Args":["queryRecords","{\"selector\":{\"docType\":\"wallet\",\"ownerIDInOrg\":\"'+params[:id]+'\",\"orgID\":\"'+ENV['BLOCKCHAIN_ORGID']+'\"},\"fields\":[\"balance\"]}"]}'
      cmnd="docker exec -it cli peer chaincode query -C mychannel -n mycc -c '"+argmnt+"'"
      puts ("\n=============\nRunning:\n"+cmnd+"\n--\n")
      output=%x(#{cmnd})
      puts("Result:\n"+output+"\n==\n")
      balance=-1
      begin
          wallet_id=output.match(/"Key":"(.+?)"/)[1]
          balance=output.match(/"Record":{"balance":(.+?)\}/)[1]
      rescue
      end
      if (params[:addtobalance].present?)
        if (params[:addtobalance]=="0")
           render json: output
           return
        end
        argmnt="{\"Args\":[\"addToClientWallet\",\""+wallet_id+"\",\""+params[:addtobalance]+"\"]}"
        cmnd="docker exec -it cli peer chaincode invoke -o orderer.example.com:7050 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n mycc --peerAddresses peer0.org1.example.com:7051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses peer0.org2.example.com:9051 --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '"+argmnt+"' --waitForEvent"
#puts ("\n=============\nRunning:\n"+cmnd+"\n--\n")
        output=%x(#{cmnd})
#puts("Result:\n"+output+"\n==\n")
        begin
          tx_no=output.match(/ txid \[(.+?)\]/)[1]
          new_balance=output.match(/balance\\":([0-9]+?)}/)[1]
          if (new_balance.length>1)
            render json: "{tx: '"+tx_no+"', balance: "+new_balance+"}"
          else
            render json: output
          end
        rescue
            render json: output
        end
      else
        render json: balance;
      end
    else
      redirect_to admin_users_path
    end
  end

  def destroy
    unless @user = User.where(id: params[:id]).first
      redirect_to admin_users_path
      return
    end
    ClaimReview.where("user_id = ?",@user.id).destroy_all
    MediumReview.where("user_id = ?",@user.id).destroy_all
    SrcReview.where("user_id = ?",@user.id).destroy_all
    Claim.where("user_id = ?",@user.id).destroy_all
    Medium.where("user_id = ?",@user.id).destroy_all
    Src.where("user_id = ?",@user.id).destroy_all
    Resource.where("user_id = ?",@user.id).destroy_all
    if @user.delete
      redirect_to admin_users_path
    end
  end

  def user_params
      params.require(:user).permit(:name, :email, :affiliation, :role, :url, :details)
  end

  def user_create_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :affiliation, :role, :url, :details)
  end

end
