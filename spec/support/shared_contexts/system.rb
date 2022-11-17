RSpec.shared_context 'login' do |user|
  visit new_user_session_path

  fill_in 'user_email', with: user.email
  fill_in 'user_password', with: user.password
  click_button 'ログイン'
end

RSpec.shared_context 'base user' do
  let(:user) { create(:user) }
  let(:member) { user.member }
end
