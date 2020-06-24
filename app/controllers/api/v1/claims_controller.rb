module Api
  module V1
    class ClaimsController < ApplicationController
      before_action :authenticate_user!
      respond_to :json

      def index
        respond_with Claim.all
      end

      def show
        respond_with Claim.find(params[:id])
      end

      def create
        if !params[:claim][:url].empty?
          params[:claim][:url]=get_preview(params[:claim][:url])
        end
        clm=current_user.claims.build(allowed_params)
        if (clm.save)
          respond_with clm
        else
          head(:error)
        end
      end

      def update
        respond_with Claim.update(params[:id], params[:claims])
      end

      def destroy
        claim=Claim.find(params[:id])
          if current_user == claim.user
            if (claim.destroy)
              head(:ok)
            else
              head(:error)
            end
          else
            head(:unauthorized)
          end
      end

      def allowed_params
          params.require(:claim).permit(:title, :has_image, :has_video, :has_text, :description, :url, :url_preview, :sharing_mode, :add_to_blockchain, :expiry_date, :reward_amount, :conditions)
      end

    end
  end
end
