class MembersController < ApplicationController
  def index
    if @roles[:admin] || @roles[:board] || @roles[:lead]
      @members = list_members
    else
      redirect_to member_path(current_user.member)
    end
  end

  def show
    @member = Member.find(params[:id])
    @users = @member.users
    @addresses = @member.addresses
    @events = Event.sorted(false)
    @payments = Event.sorted(true)
    @attendances = Attendance.in(event_id: @events.pluck(:id)).index_by(&:event_id)
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
    params[:member][:roles] = params[:member][:roles].reject(&:blank?)
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

  def list_members
    years =
      if @roles[:admin] || @roles[:board]
        Year.all.order(anno_domini: :desc)
      else
        current_user.member.year
      end

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
    @years = Year.all.sort(anno_domini: :desc).pluck(:graduate_year, :id).to_h
    @communications = %w[メール 郵便 退会 逝去]
    @role_options = [
      %w[lead 同学年全員の情報へアクセス可能],
      %w[board 全員の情報へアクセス可能],
      %w[admin 幹事同等権限＋メンバーの権限変更]
    ]
  end
end
