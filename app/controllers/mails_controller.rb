class MailsController < ApplicationController
  before_action :check_roles_mails

  def index
    @mails = generate_csv
  end

  private

  def check_roles_mails
    # Accept other than normal users
    return true if @roles[:lead] || @roles[:admin] || @roles[:board]

    # Access denied
    redirect_to(members_path)
  end

  def generate_csv
    names = {}
    list_members.each { |m| names[m.id] = "#{m.family_name} #{m.first_name}" }

    str = []
    list_mails.each do |member_id, mails|
      mails.each do |mail|
        str << "#{names[member_id]}<#{mail}>"
      end
    end

    str
  end

  def list_mails
    mails = {}
    list_members.each { |i| mails[i.id] = [] }
    User.where(unreachable: false).in(member_id: list_members.pluck(:id)).each do |user|
      mails[user.member_id] << user.email
    end

    mails
  end

  def list_members
    years = Year.accessible_years(roles: @roles, current_user:)
    Member.in(year_id: years.pluck(:id)).order(search_key: :asc)
  end
end
