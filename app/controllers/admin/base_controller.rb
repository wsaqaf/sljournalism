class Admin::BaseController < ApplicationController

  def index
    @users = User.all
  end
end
