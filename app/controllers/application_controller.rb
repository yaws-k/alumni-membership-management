class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :user_roles

  def user_roles
    return if current_user.blank?

    # Member info
    member = current_user.member
    @current_member_id = member.id
    @current_member_year_id = member.year_id

    # Member roles
    @roles = {
      lead: member.roles.include?('lead'),
      board: member.roles.include?('board'),
      admin: member.roles.include?('admin')
    }
  end
end
