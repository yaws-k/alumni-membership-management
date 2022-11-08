class Members::UsersController < ApplicationController
  before_action :check_roles

  def new
    @member = Member.find(params[:member_id])
    @user = @member.users.build
  end

  def create
    if params[:user][:password].blank?
      # Set random password if it wasn't specified
      params[:user][:password] = SecureRandom.alphanumeric(10)
      params[:user][:password_confirmation] = params[:user][:password]
    end

    @user = User.new(user_params)
    unless @user.save
      render 'new', status: :unprocessable_entity
      return
    end

    redirect_to member_path(@user.member_id)
  end

  def edit
    @user = User.find(params[:id])
    redirect_to(members_path) if @user.member_id.to_s != params[:member_id]
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete('password')
      params[:user].delete('password_confirmation')
    end

    @user = User.find(params[:id])
    if @user.member_id.to_s != params[:member_id]
      redirect_to(members_path)
      return
    end

    unless @user.update(user_params)
      render 'edit', status: :unprocessable_entity
      return
    end

    redirect_to member_path(@user.member_id)
  end

  def destroy
    @user = User.find(params[:id])
    if @user.member_id.to_s != params[:member_id]
      redirect_to(members_path)
      return
    end

    @user.destroy
    redirect_to(member_path(@user.member_id), notice: "#{@user.email}を削除しました。")
  end

  private

  def user_params
    params[:user][:member_id] = params[:member_id]
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :unreachable,
      :member_id
    )
  end
end
