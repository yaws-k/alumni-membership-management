class PaymentsController < ApplicationController
  before_action :check_roles_payments

  def index
    @payments = Event.sorted(payment_only: true)
  end

  def show
    @payment = Event.find(params[:id])
    @attendances = @payment.attendances.index_by(&:member_id)
    @members = Member.in(id: @attendances.keys)
    @years = Year.all.index_by(&:id)
  end

  def new
    @payment = Event.new(payment_only: true)
  end

  def create
    @payment = Event.new(payment_params)
    unless @payment.save
      render 'new', status: :unprocessable_entity
      return
    end
    redirect_to payments_path
  end

  def edit
    @payment = Event.find(params[:id])
  end

  def update
    @payment = Event.find(params[:id])
    unless @payment.update(payment_params)
      render 'edit', status: :unprocessable_entity
      return
    end
    redirect_to payments_path
  end

  def destroy
    @payment = Event.find(params[:id])

    if @payment.attendances.blank?
      @payment.destroy
      redirect_to(payments_path, notice: "#{@payment.event_name}を削除しました。")
    else
      redirect_to(payments_path, alert: "関連する支払いがあるため、#{@payment.event_name}を削除できませんでした。")
    end
  end

  private

  def payment_params
    params.require(:event).permit(
      :event_name,
      :event_date,
      :fee,
      :payment_only,
      :annual_fee,
      :note
    )
  end

  def check_roles_payments
    # Admin and Board member can access anywhere
    return true if @roles[:admin] || @roles[:board]

    # Access denied
    redirect_to(members_path, alert: 'Access denied')
  end
end
