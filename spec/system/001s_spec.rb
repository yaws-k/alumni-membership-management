require 'rails_helper'

RSpec.describe "001s", type: :system do
  before do
    driven_by(:rack_test)
  end

  include_context 'base user'

  RSpec.shared_examples 'login check' do
    it 'is possible to login' do
      visit new_user_session_path
      expect(page).to have_text('Log in')

      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
      click_button 'commit'

      expect(page).to have_text('Signed in successfully.')
      expect(page).to have_button('Logout')
    end
  end

  context 'normal user' do
    it_behaves_like 'login check'
  end

  context 'lead' do
    before { member.update(roles: %w[lead]) }
    it_behaves_like 'login check'
  end

  context 'board' do
    before { member.update(roles: %w[board]) }
    it_behaves_like 'login check'
  end

  context 'admin' do
    before { member.update(roles: %w[admin]) }
    it_behaves_like 'login check'
  end
end
