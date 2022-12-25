require 'rails_helper'

RSpec.describe "013s", type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  it 'accepts anybody' do
    visit new_user_session_path
    expect(current_path).to eq(new_user_session_path)
  end

  it 'redirects any direct access to login page' do
    visit members_path
    expect(current_path).to eq(new_user_session_path)

    visit events_path
    expect(current_path).to eq(new_user_session_path)

    visit payments_path
    expect(current_path).to eq(new_user_session_path)

    visit years_path
    expect(current_path).to eq(new_user_session_path)
  end

  it 'rejects invalid login' do
    visit new_user_session_path

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'invalid password'
    click_button 'ログイン'

    expect(page).to have_text('Invalid Email or password.')
  end
end
