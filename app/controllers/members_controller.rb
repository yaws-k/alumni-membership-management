class MembersController < ApplicationController
  before_action :reject_normal_members, only: %i[new create destroy]
  before_action :check_roles_members, only: %i[show create edit update destroy]

  def index
    if @roles[:admin] || @roles[:board] || @roles[:lead]
      @members = list_members
      @payments = Member.payment_status
    else
      redirect_to member_path(current_user.member)
    end
  end

  def show
    @member = Member.find(params[:id])
    @users = @member.users
    @addresses = @member.addresses
    @payments = Event.sorted(payment_only: true)
    @payment_dates = Attendance.in(event_id: @payments.pluck(:id), member_id: @member.id).index_by(&:event_id)
    @events = Event.sorted(payment_only: false)
    @attendances = @member.attendances.in(event_id: @events.pluck(:id)).index_by(&:event_id)
    @events.each do |event|
      @attendances[event.id] = @member.attendances.create(event_id: event.id) if @attendances[event.id].blank?
    end
  end

  def new
    @member = Member.new
    prepare_options
  end

  def create
    @member = Member.new(member_params)
    unless @member.save
      prepare_options
      render :new, status: :unprocessable_entity
      return
    end

    redirect_to member_path(@member)
  end

  def edit
    @member = Member.find(params[:id])
    prepare_options
  end

  def update
    @member = Member.find(params[:id])
    unless @member.update(member_params)
      prepare_options
      render :edit, status: :unprocessable_entity
      return
    end

    redirect_to member_path(@member)
  end

  def destroy
    @member = Member.find(params[:id])
    @member.destroy
    redirect_to(members_path, notice: "#{@member.family_name} #{@member.first_name}を削除しました。")
  end

  private

  def member_params
    params[:member][:roles] = params[:member][:roles].reject(&:blank?) if params[:member][:roles].present?
    params.require(:member).permit(
      :year_id,
      :family_name_phonetic,
      :maiden_name_phonetic,
      :first_name_phonetic,
      :family_name,
      :maiden_name,
      :first_name,
      :communication,
      :quit_reason,
      :occupation,
      :note,
      roles: []
    )
  end

  # Access check
  def check_roles_members
    # Admin and Board member can access anywhere
    return if @roles[:admin] || @roles[:board]

    if params[:id].present?
      # For show, edit, update, destroy
      target_member = Member.find(params[:id])
    elsif member_params[:year_id].present?
      # For create
      target_member = Member.new(year_id: member_params[:year_id])
    end

    # Lead can access only when the target member is the same graduate year
    return if @roles[:lead] && (target_member.year_id == @current_member.year_id)

    # Normal user can access only their own information
    return if target_member.id == @current_member.id

    # Access denied
    redirect_to(members_path)
  end

  def reject_normal_members
    redirect_to(members_path) if @roles.values.uniq == [false]
  end

  def list_members
    years = Year.accessible_years(roles: @roles, current_user:)

    members = {}
    years.each do |year|
      members[year.id] = {
        year:,
        count: 0,
        members: []
      }
    end

    Member.in(year_id: members.keys).order(search_key: :asc).each do |member|
      members[member.year_id][:count] += 1
      members[member.year_id][:members] << member
    end
    members
  end

  def prepare_options
    @years = Year.accessible_years(roles: @roles, current_user:).pluck(:graduate_year, :id).to_h
    @communications = %w[メール 郵便 退会 逝去]
    @role_options = [
      %w[lead 同学年全員の情報へアクセス可能],
      %w[board 全員の情報へアクセス可能],
      %w[admin 幹事同等権限＋メンバーの権限変更]
    ]
  end
end
