class ExportsController < ApplicationController
  before_action :check_roles_exports

  def emails
    names = member_names
    @emails = []
    list_emails(names.keys).each do |member_id, mails|
      mails.each do |mail|
        @emails << "#{names[member_id]}<#{mail}>"
      end
    end
  end

  def event_participants
    event = Event.find(params[:event_id])
    applied = event.attendances.where(application: true).pluck(:id)
    present = event.attendances.where(presence: true).pluck(:id)
    attendances = Attendance.in(id: (applied + present)).index_by(&:member_id)
    members = Member.year_sort(id: attendances.keys, order: :asc)
    years = Year.order(anno_domini: :desc).index_by(&:id)
    counts = {
      application: event.attendances.where(application: true).size,
      presence: event.attendances.where(presence: true).size
    }

    docs = { event:, attendances:, members:, years:, counts: }

    workbook = RubyXL::Parser.parse("#{Rails.root}/lib/assets/event_participants_template.xlsx")
    fill_participants_sheet(workbook:, docs:)

    send_data(workbook.stream.read, filename: "participants_#{Date.today}.xlsx", disposition: 'attachment')
  end

  def members
    years = Year.accessible_years(roles: @roles, current_user:).pluck(:id, :graduate_year).to_h
    members = Member.in(year_id: years.keys).order(search_key: :asc)
    payment_status = Member.payment_status

    users = {}
    User.in(member_id: members.pluck(:id)).where(unreachable: false).order(email: :asc).each do |user|
      users[user.member_id] ||= []
      users[user.member_id] << user
    end

    addresses = {}
    Address.in(member_id: members.pluck(:id)).where(unreachable: false).order(postal_code: :asc).each do |address|
      addresses[address.member_id] ||= []
      addresses[address.member_id] << address
    end

    docs = { years:, members:, payment_status:, users:, addresses: }

    workbook = RubyXL::Parser.parse("#{Rails.root}/lib/assets/members_template.xlsx")
    fill_asof(workbook:)
    fill_member_sheet(workbook:, docs:)
    fill_email_sheet(workbook:, docs:)
    fill_address_sheet(workbook:, docs:)
    fill_full_sheet(workbook:, docs:)

    send_data(workbook.stream.read, filename: "members_#{Date.today}.xlsx", disposition: 'attachment')
  end

  private

  def check_roles_exports
    # Accept other than normal users
    return true if @roles[:lead] || @roles[:admin] || @roles[:board]

    # Access denied
    redirect_to(members_path)
  end

  #
  # emails
  #
  def list_emails(member_id)
    emails = {}
    member_id.each { |m| emails[m] = [] }
    User.where(unreachable: false).in(member_id:).each do |u|
      emails[u.member_id] << u.email
    end
    emails
  end

  def member_names
    names = {}
    years = Year.accessible_years(roles: @roles, current_user:)
    Member.in(year_id: years.pluck(:id)).order(search_key: :asc).each do |m|
      names[m.id] = "#{m.family_name} #{m.first_name}"
    end
    names
  end

  #
  # event participants
  #
  def event_presence(flag)
    case flag
    when true
      '出席'
    when false
      '欠席'
    else
      '未入力'
    end
  end

  def fill_participants_sheet(workbook:, docs:)
    # docs = { event:, attendances:, members:, years:, counts: }
    workbook[0].add_cell(0, 1, docs[:event].event_name)
    workbook[0].add_cell(1, 1, docs[:event].event_date.to_s.tr('-', '/'))
    workbook[0].add_cell(2, 1, docs[:event].fee)

    workbook[0].add_cell(4, 1, docs[:counts][:application])
    workbook[0].add_cell(5, 1, docs[:counts][:presence])

    workbook[0].add_cell(7, 4, Time.now.localtime.strftime('%F %T'))

    row = 9
    docs[:members].each do |member|
      workbook[0].add_cell(row, 0, docs[:years][member.year_id].graduate_year)
      workbook[0].add_cell(row, 1, ApplicationController.helpers.full_name(member)[0])
      workbook[0].add_cell(row, 2, event_presence(docs[:attendances][member.id].application))
      workbook[0].add_cell(row, 3, event_presence(docs[:attendances][member.id].presence))
      workbook[0].add_cell(row, 4, docs[:attendances][member.id].note)
      workbook[0].add_cell(row, 5, docs[:attendances][member.id].payment_date.to_s.tr('-', '/'))
      row += 1
    end
  end

  #
  # members
  #
  def convert_roles(roles)
    tmp = []
    roles.each do |role|
      tmp << ApplicationController.helpers.role_name(role)
    end
    tmp.join('、')
  end

  # member export
  def common_cols(m: nil, years: {})
    [
      m.id.to_s,
      "#{years[m.year_id]}回卒",
      m.family_name_phonetic,
      m.first_name_phonetic,
      m.maiden_name_phonetic,
      m.family_name,
      m.first_name,
      m.maiden_name
    ]
  end

  def fill_asof(workbook: nil)
    workbook[0].add_cell(0, 0, "As of: #{Time.now.localtime.strftime('%F %T')}")
  end

  def fill_member_sheet(workbook: nil, docs: {})
    ws = workbook[1]
    row = 1

    docs[:members].each do |m|
      tmp = common_cols(m:, years: docs[:years])

      ws.add_cell(row, 0, tmp[0])
      ws.add_cell(row, 1, tmp[1])
      ws.add_cell(row, 2, tmp[2])
      ws.add_cell(row, 3, tmp[3])
      ws.add_cell(row, 4, tmp[4])
      ws.add_cell(row, 5, tmp[5])
      ws.add_cell(row, 6, tmp[6])
      ws.add_cell(row, 7, tmp[7])
      ws.add_cell(row, 8, convert_roles(m.roles))
      ws.add_cell(row, 9, m.communication)
      ws.add_cell(row, 10, m.quit_reason)
      ws.add_cell(row, 11, m.occupation)
      ws.add_cell(row, 12, docs[:payment_status][m.id].to_s)
      ws.add_cell(row, 13, m.note)

      row += 1
    end
  end

  def fill_email_sheet(workbook: nil, docs: {})
    ws = workbook[2]
    row = 1

    docs[:members].each do |m|
      next if docs[:users][m.id].blank?

      tmp = common_cols(m:, years: docs[:years])

      docs[:users][m.id].each do |user|
        ws.add_cell(row, 0, tmp[0])
        ws.add_cell(row, 1, tmp[1])
        ws.add_cell(row, 2, tmp[2])
        ws.add_cell(row, 3, tmp[3])
        ws.add_cell(row, 4, tmp[4])
        ws.add_cell(row, 5, tmp[5])
        ws.add_cell(row, 6, tmp[6])
        ws.add_cell(row, 7, tmp[7])
        ws.add_cell(row, 8, user.email)

        row += 1
      end
    end
  end

  def fill_address_sheet(workbook: nil, docs: {})
    ws = workbook[3]
    row = 1

    docs[:members].each do |m|
      next if docs[:addresses][m.id].blank?

      tmp = common_cols(m:, years: docs[:years])

      docs[:addresses][m.id].each do |address|
        ws.add_cell(row, 0, tmp[0])
        ws.add_cell(row, 1, tmp[1])
        ws.add_cell(row, 2, tmp[2])
        ws.add_cell(row, 3, tmp[3])
        ws.add_cell(row, 4, tmp[4])
        ws.add_cell(row, 5, tmp[5])
        ws.add_cell(row, 6, tmp[6])
        ws.add_cell(row, 7, tmp[7])
        ws.add_cell(row, 8, address.postal_code)
        ws.add_cell(row, 9, address.address1)
        ws.add_cell(row, 10, address.address2)

        row += 1
      end
    end
  end

  def fill_full_sheet(workbook: nil, docs: {})
    ws = workbook[4]
    row = 1

    docs[:members].each do |m|
      tmp = common_cols(m:, years: docs[:years])

      ws.add_cell(row, 0, tmp[0])
      ws.add_cell(row, 1, tmp[1])
      ws.add_cell(row, 2, tmp[2])
      ws.add_cell(row, 3, tmp[3])
      ws.add_cell(row, 4, tmp[4])
      ws.add_cell(row, 5, tmp[5])
      ws.add_cell(row, 6, tmp[6])
      ws.add_cell(row, 7, tmp[7])
      ws.add_cell(row, 8, convert_roles(m.roles))
      ws.add_cell(row, 9, m.communication)
      ws.add_cell(row, 10, m.quit_reason)
      ws.add_cell(row, 11, m.occupation)
      ws.add_cell(row, 12, docs[:payment_status][m.id].to_s)
      ws.add_cell(row, 13, join_emails(member: m, users: docs[:users]))
      ws.add_cell(row, 14, join_addresses(member: m, addresses: docs[:addresses]))
      ws.add_cell(row, 15, m.note)

      row += 1
    end
  end

  def join_emails(member: nil, users: nil)
    return nil if users[member.id].blank?

    users[member.id].pluck(:email).join("\n")
  end

  def join_addresses(member: nil, addresses: nil)
    return nil if addresses[member.id].blank?

    array = []
    addresses[member.id].pluck(:postal_code, :address1, :address2).each do |address|
      array << address.join('　')
    end
    array.join("\n")
  end
end
