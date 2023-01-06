class StatisticsController < ApplicationController
  before_action :check_roles_statistics

  def members
    @stats = count_members
  end

  private

  def check_roles_statistics
    # More than lead role required
    return true if @roles[:lead] || @roles[:admin] || @roles[:board]

    # Access denied
    redirect_to(members_path, alert: 'Access denied')
  end

  def count_members
    member_counts = Member.in(communication: %w[メール 郵便]).tally(:year_id)
    annual_fee_paid_counts = annual_fee_paid
    leads = lead_list

    array = []
    Year.order(anno_domini: :desc).each do |y|
      tmp = []
      tmp << y
      tmp << member_counts.fetch(y.id, 0)
      tmp << annual_fee_paid_counts.fetch(y.id, 0)

      if leads[y.id].blank?
        tmp.concat([nil, nil])
      else
        tmp << leads[y.id][:names].join("\n")
        tmp << leads[y.id][:emails].join("\n")
      end

      array << tmp
    end
    array
  end

  def annual_fee_paid
    hash = Hash.new(0)
    status = Member.payment_status
    Member.all.each do |m|
      next if %w[- 未済].include?(status[m.id])

      hash[m.year_id] += 1
    end
    hash
  end

  def lead_list
    list = {}
    members = Member.where(roles: 'lead')

    users = {}
    User.in(member_id: members.pluck(:id)).where(unreachable: false).each do |u|
      users[u.member_id] ||= []
      users[u.member_id] << u.email
    end

    members.each do |m|
      list[m.year_id] ||= { names: [], emails: [] }
      list[m.year_id][:names] << "#{m.family_name} #{m.first_name}"
      next if users[m.id].blank?

      list[m.year_id][:emails] << users[m.id].join(', ')
    end
    list
  end
end
