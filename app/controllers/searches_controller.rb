class SearchesController < ApplicationController
  before_action :check_roles_searches

  def name
    # keyword
    @search = normalized_search_key

    # Accessible year hash and members
    @year, members = accessible_years_members

    # Scan Memeber.search_key
    @members = search(array: members.pluck(:search_key, :id), keyword: @search)

    # Payment status
    @payments = Member.payment_status
  end

  def email
    # keyword
    @search = normalized_search_key

    # Accessible year hash and members
    @year, members = accessible_years_members

    # Scan User.email
    users = User.in(member_id: members.pluck(:id)).pluck(:email, :member_id)
    @members = search(array: users, keyword: @search)

    # Payment status
    @payments = Member.payment_status
  end

  private

  def check_roles_searches
    # Accept other than normal users
    return true if @roles[:lead] || @roles[:admin] || @roles[:board]

    # Access denied
    redirect_to(members_path)
  end

  # Search
  def accessible_years_members
    # Accessible years and year hash
    year = Year.accessible_years(roles: @roles, current_user:)
    year_h = year.pluck(:id, :graduate_year)

    # Accessible members
    members = Member.in(year_id: year.pluck(:id))

    [year_h, members]
  end

  def normalized_search_key
    params[:search].strip.unicode_normalize(:nfkc).tr('ァ-ン', 'ぁ-ん')
  end

  def search(array: [], keyword: nil)
    return [] if keyword.blank?

    rp = Regexp.new("#{keyword}.*?:")
    ids = array.map{ |a| a.join(':') }.grep(rp) { |i| i.split(':')[1] }
    return [] if ids.blank?

    Member.in(id: ids.uniq).order(search_key: :asc)
  end
end
