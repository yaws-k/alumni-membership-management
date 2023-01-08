class SearchesController < ApplicationController
  before_action :check_roles_searches

  def name
    @search = params[:search].strip.unicode_normalize(:nfkc).tr('ァ-ン', 'ぁ-ん')

    year = Year.accessible_years(roles: @roles, current_user:)
    @year = year.pluck(:id, :graduate_year)

    members = Member.in(year_id: year.pluck(:id)).pluck(:search_key, :id)
    member_ids = search(array: members, keyword: @search)

    @members = Member.in(id: member_ids).order(search_key: :asc)

    @payments = Member.payment_status
  end

  def email
  end

  private

  def check_roles_searches
    # Accept other than normal users
    return true if @roles[:lead] || @roles[:admin] || @roles[:board]

    # Access denied
    redirect_to(members_path)
  end

  def search(array: [], keyword: nil)
    return [] if keyword.blank?

    ids = array.map{ |a| a.join(':') }.grep(/#{keyword}.*?:/) { |i| i.split(':')[1] }
    return [] if ids.blank?

    ids
  end
end
