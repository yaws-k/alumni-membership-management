class PaymentHistoriesController < ApplicationController
  before_action :check_roles_payment_histories

  def new
    @attendance = Attendance.new(member_id: params[:member_id])
    @member_id = params[:member_id]

    @payments = payment_select
  end

  def create
    @attendance = Attendance.new(attendance_params)
    @member_id = @attendance.member_id

    # Amount and Payment Date must be filled
    if @attendance.amount.zero? || @attendance.payment_date.blank?
      @payments = payment_select
      render 'new', status: :unprocessable_entity
      return
    end

    unless @attendance.save
      @payments = payment_select
      render 'new', status: :unprocessable_entity
      return
    end
    redirect_to member_path(@attendance.member_id, anchor: 'payment')
  end

  def edit
    @attendance = Attendance.find(params[:id])
    @member_id = @attendance.member_id

    @payments = payment_select
  end

  def update
    @attendance = Attendance.find(params[:id])
    @member_id = @attendance.member_id

    unless @attendance.update(attendance_params)
      @payments = payment_select
      render 'edit', status: :unprocessable_entity
      return
    end

    # Amount and Payment Date must be filled
    if @attendance.amount.zero? || @attendance.payment_date.blank?
      @payments = payment_select
      render 'edit', status: :unprocessable_entity
      return
    end

    redirect_to member_path(@attendance.member_id, anchor: 'payment')
  end

  def destroy
    @attendance = Attendance.find(params[:id])
    member_id = @attendance.member_id
    @attendance.destroy

    redirect_to(member_path(member_id, anchor: 'payment'), notice: "#{@attendance.event.event_name}を削除しました。")
  end

  private

  def attendance_params
    params.require(:attendance).permit(
      :member_id,
      :event_id,
      :payment_date,
      :amount,
      :note
    )
  end

  def check_roles_payment_histories
    # Admin and Board member can access anywhere
    return true if @roles[:admin] || @roles[:board]

    # Access denied
    redirect_to(members_path, alert: 'Access denied')
  end

  def payment_select
    Event.sorted(payment_only: true).pluck(:event_name, :id)
  end
end
