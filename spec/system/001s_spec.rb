require 'rails_helper'

RSpec.describe "001s", type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  def login_check(user: nil)
    visit new_user_session_path
    expect(page).to have_text('Log in')

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'commit'

    expect(page).to have_text('Signed in successfully.')
    expect(page).to have_button('Logout')
  end

  context 'normal user' do
    it 'is possible to login' do
      login_check(user:)
    end
  end

  context 'lead' do
    it 'is possible to login' do
      member.update(roles: %w[lead])
      login_check(user:)
    end
  end

  context 'board' do
    it 'is possible to login' do
      member.update(roles: %w[board])
      login_check(user:)
    end
  end

  context 'admin' do
    it 'is possible to login' do
      member.update(roles: %w[admin])
      login_check(user:)
    end
  end
end
