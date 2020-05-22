module Api
  module V1
    class SessionsController < ApplicationController
      respond_to :json

      def create
        user = User.where(email: params[:email]).first
        if user&.valid_password?(params[:password])
          render json: user.as_json(only: [:id, :authentication_token]), status: :created
        else
          head(:unauthorized)
        end
      end

      def destroy
        if !current_user
          head(:unauthorized)
        else
          current_user.authentication_token = nil
          if current_user.save
            head(:ok)
          else
            head(:unauthorized)
          end
        end
      end

    end
  end
end
