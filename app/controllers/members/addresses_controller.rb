class Members::AddressesController < ApplicationController
  before_action :check_roles
  before_action :consistency_check, except: %i[new create]

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
    # Variables are set in before_action
  end

  def update
    unless @address.update(address_params)
      render 'edit', status: :unprocessable_entity
      return
    end

    redirect_to member_path(@address.member_id)
  end

  def destroy
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

  def consistency_check
    @member = Member.find(params[:member_id])
    @address = Address.find(params[:id])
    redirect_to(members_path) if @member.id != @address.member.id
  end
end
