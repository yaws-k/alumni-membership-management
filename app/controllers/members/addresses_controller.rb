class Members::AddressesController < ApplicationController
  before_action :check_roles

  def new
    @member = Member.find(params[:member_id])
    @address = @member.addresses.build
  end

  def create
    @address = Address.new(address_params)
    unless @address.save
      render 'new', status: :unprocessable_entity
      return
    end

    redirect_to member_path(@address.member_id)
  end

  def edit
    @address = Address.find(params[:id])
    redirect_to(members_path) if @address.member_id.to_s != params[:member_id]
  end

  def update
    @address = Address.find(params[:id])
    if @address.member_id.to_s != params[:member_id]
      redirect_to(members_path)
      return
    end

    unless @address.update(address_params)
      render 'edit', status: :unprocessable_entity
      return
    end

    redirect_to member_path(@address.member_id)
  end

  def destroy
    @address = Address.find(params[:id])
    if @address.member_id.to_s != params[:member_id]
      redirect_to(members_path)
      return
    end

    @address.destroy
    redirect_to(member_path(@address.member_id), notice: "#{@address.postal_code}　#{@address.address1}　#{@address.address2}を削除しました。")
  end

  private

  def address_params
    params[:address][:member_id] = params[:member_id]
    params.require(:address).permit(
      :postal_code,
      :address1,
      :address2,
      :unreachable,
      :member_id
    )
  end
end
