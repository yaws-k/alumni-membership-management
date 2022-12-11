RSpec.shared_context 'login' do
  before do
    visit new_user_session_path

    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: user.password
    click_button 'ログイン'
  end
end

RSpec.shared_context 'login as lead' do
  before { user.member.update(roles: %w[lead]) }
  include_context 'login'
end

RSpec.shared_context 'login as board' do
  before { user.member.update(roles: %w[board]) }
  include_context 'login'
end

RSpec.shared_context 'base user' do
  let!(:user) { create(:user) }
  let!(:member) { user.member }
  let!(:year) { member.year }
  let!(:payment) { create(:event, :payment, event_name: '年会費') }
end
