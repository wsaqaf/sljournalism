module Api
  module V1
    class ClaimReviewsController < ApplicationController
      before_action :authenticate_user!
      respond_to :json

      def index
        respond_with ClaimReview.all
      end

      def show
        respond_with ClaimReview.find(params[:id])
      end

      def create
        respond_with ClaimReview.create(params[:claim_reviews])
      end

      def update
        respond_with ClaimReview.update(params[:id], params[:claim_reviews])
      end

      def destroy
        respond_with ClaimReview.destroy(params[:id])
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
