class StatisticsController < ApplicationController
  def members
    if @roles[:lead] || @roles[:admin] || @roles[:board]
      @stats = count_members
    else
      redirect_to(members_path, alert: 'Access denied')
    end
  end

  def incomes
    # @incomes = {
    #   '2022/09/01-2023/08/31' => {
    #     '2022/12' => [
    #       { attendance_domid: ..., payment_date: ... },
    #       { ... }
    #     ],
    #     '2022-11' => { ... },
    #   }
    #
    # @counts = {
    #   '2022/09/01-2023/08/31' =>  count: 123, amount: 456789 },
    #   '2022/12' => { count: 3, amount: 7000 },
    #   '2022/11' => { ... }
    # }
    if @roles[:admin] || @roles[:board]
      @incomes, @counts = list_incomes
    else
      redirect_to(members_path, alert: 'Access denied')
    end
  end

  def annual_fees
    if @roles[:admin] || @roles[:board]
      @annual_fees, @counts = list_annual_fees
    else
      redirect_to(members_path, alert: 'Access denied')
    end
  end

  def donations
  end

  private

  #
  # members
  #
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

  #
  # common methods for incomes/annual_fees/donations
  #
  def related_docs(payments: nil)
    payment_name = payments.pluck(:id, :event_name).to_h
    attendances = Attendance.in(event_id: payments.pluck(:id)).where(:payment_date.gte => Date.new(2019, 7, 26)).sort(payment_date: :desc)
    graduate_years = Year.pluck(:id, :graduate_year).to_h
    members = Member.in(id: attendances.pluck(:member_id)).index_by(&:id)

    array = []
    attendances.each do |a|
      array << {
        attendance_domid: "attendance_#{a.id}",
        payment_date: a.payment_date,
        graduate_year: "#{graduate_years[members[a.member_id].year_id]}回卒",
        member_id: members[a.member_id].id,
        family_name: members[a.member_id].family_name,
        family_name_phonetic: members[a.member_id].family_name_phonetic,
        first_name: members[a.member_id].first_name,
        first_name_phonetic: members[a.member_id].first_name_phonetic,
        amount: a.amount,
        event_name: payment_name[a.event_id]
      }
    end
    array
  end

  #
  # incomes
  #
  def list_incomes
    incomes = {}
    counts = {}
    payments = Event.sorted(payment_only: true)

    related_docs(payments:).each do |income|
      fiscal_year = fiscal_year(income[:payment_date])
      yymm = income[:payment_date].strftime('%Y/%m')
      incomes[fiscal_year] ||= {}
      incomes[fiscal_year][yymm] ||= []
      incomes[fiscal_year][yymm] << income

      counts[fiscal_year] ||= { count: 0, amount: 0 }
      counts[fiscal_year][:count] += 1
      counts[fiscal_year][:amount] += income[:amount]

      counts[yymm] ||= { count: 0, amount: 0 }
      counts[yymm][:count] += 1
      counts[yymm][:amount] += income[:amount]
    end
    [incomes, counts]
  end

  def fiscal_year(date)
    if date.month <= 8
      "#{date.year - 1}/09/01-#{date.year}/08/31"
    else
      "#{date.year}/09/01-#{date.year + 1}/08/31"
    end
  end

  #
  # annual_fees
  #
  def list_annual_fees
    annual_fees = {}
    counts = {}
    payments = Event.where(payment_only: true, annual_fee: true).sort(event_date: :desc)

    related_docs(payments:).each do |income|
      annual_fee_period = income[:event_name]
      yymm = income[:payment_date].strftime('%Y/%m')
      annual_fees[annual_fee_period] ||= {}
      annual_fees[annual_fee_period][yymm] ||= []
      annual_fees[annual_fee_period][yymm] << income

      counts[annual_fee_period] ||= { count: 0, amount: 0 }
      counts[annual_fee_period][:count] += 1
      counts[annual_fee_period][:amount] += income[:amount]

      counts[yymm] ||= { count: 0, amount: 0 }
      counts[yymm][:count] += 1
      counts[yymm][:amount] += income[:amount]
    end
    [annual_fees, counts]
  end
end
