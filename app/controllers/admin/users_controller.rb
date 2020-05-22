class Admin::UsersController < Admin::BaseController

  def index
    @users = User.all.order(Arel.sql("updated_at DESC"))
  end

  def edit
    unless @user = User.where(id: params[:id]).first
      redirect_to admin_users_path
    end
#      redirect_to edit_admin_user_path(@user.id)
  end

  def create
    @user = User.create(user_create_params)
    if @user.save
        redirect_to admin_users_path
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
