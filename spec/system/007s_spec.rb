require 'rails_helper'

RSpec.describe '007s', type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  it 'locks the account after 5 attempts' do
    visit new_user_session_path

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'invalid password'
    click_button 'ログイン'

    expect(page).to have_text('Invalid Email or password.')

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'invalid password'
    click_button 'ログイン'

    expect(page).to have_text('Invalid Email or password.')

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'invalid password'
    click_button 'ログイン'

    expect(page).to have_text('Invalid Email or password.')

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'invalid password'
    click_button 'ログイン'

    expect(page).to have_text('You have one more attempt before your account is locked.')

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'invalid password'
    click_button 'ログイン'

    expect(page).to have_text('Your account is locked.')
  end
end
