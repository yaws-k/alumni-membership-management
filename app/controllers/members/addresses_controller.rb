class Members::AddressesController < ApplicationController
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
  end

  def update
    @address = Address.find(params[:id])
    unless @address.update(address_params)
      render 'edit', status: :unprocessable_entity
      return
    end

    redirect_to member_path(@address.member_id)
  end

  def destroy
    @address = Address.find(params[:id])
    @address.destroy
    redirect_to(member_path(@address.member_id), notice: "#{@address.postal_code}　#{@address.address1}　#{@address.address2}を削除しました。")
  end

  private

  def address_params
    params.require(:address).permit(
      :postal_code,
      :address1,
      :address2,
      :unreachable,
      :member_id
    )
  end
end
