class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :user_roles

  def user_roles
    return if current_user.blank?

    @roles = {
      lead: false,
      board: false,
      admin: false
    }
    @roles[:lead] = true if current_user.member.roles.include?('lead')
    @roles[:board] = true if current_user.member.roles.include?('board') || current_user.member.roles.include?('admin')
    @roles[:admin] = true if current_user.member.roles.include?('admin')
  end
end
