class AttendancesController < ApplicationController
  def edit
    @attendance = Attendance.find(params[:id])

    check_roles(member_id: @attendance.member_id)
    return if performed?

    @application = { '出席' => true, '欠席' => false }
  end

  def update
    attendance = Attendance.find(params[:id])

    check_roles(member_id: attendance.member_id)
    return if performed?

    attendance.update!(attendance_params)
    redirect_to member_path(attendance.member_id, anchor: helpers.dom_id(attendance))
  end

  private

  def attendance_params
    params.require(:attendance).permit(
      :application,
      :presence,
      :payment_date,
      :amount,
      :note,
      :member_id,
      :event_id
    )
  end
end
