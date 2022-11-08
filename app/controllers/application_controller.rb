class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :user_roles

  # Access check
  def check_roles(member_id: params[:member_id])
    # Admin and Board member can access anywhere
    return true if @roles[:admin] || @roles[:board]

    if member_id.present?
      target_member = Member.find(member_id)

      # Lead can access only when the target member is the same graduate year
      return true if @roles[:lead] && (target_member.year_id == @current_member.year_id)

      # Normal user can access only their own information
      return true if target_member.id == @current_member.id
    end

    # Access denied
    redirect_to(members_path)
  end

  def user_roles
    return if current_user.blank?

    # Member info
    @current_member = current_user.member

    # Member roles
    @roles = {
      lead: @current_member.roles.include?('lead'),
      board: @current_member.roles.include?('board'),
      admin: @current_member.roles.include?('admin')
    }
  end
end
