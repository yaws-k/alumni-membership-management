class AttendancesController < ApplicationController
  def edit
    @attendance = Attendance.find(params[:id])
    @application = { '出席' => true, '欠席' => false }
  end

  def update
    attendance = Attendance.find(params[:id])
    attendance.update!(attendance_params)
    redirect_to member_path(attendance.member_id, anchor: attendance.id)
  end

  private

  def attendance_params
    params.require(:attendance).permit(
      :application,
      :presence,
      :payment,
      :amount,
      :note
    )
  end
end