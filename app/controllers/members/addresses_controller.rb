class Members::AddressesController < ApplicationController
  before_action :check_roles

  def new
    @member = Member.find(params[:member_id])
    @address = @member.addresses.build
  end

  def create
    @address = Address.new(address_params)
    @address.member_id = params[:member_id]
    unless @address.save
      render 'new', status: :unprocessable_entity
      return
    end

    redirect_to member_path(@address.member_id)
  end

  def edit
    @address = Address.find(params[:id])
    @member = @address.member
  end

  def update
    @address = Address.find(params[:id])

    unless @address.update(address_params)
      @member = @address.member
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
    params.require(:address).permit(
      :postal_code,
      :address1,
      :address2,
      :unreachable
    )
  end
end
