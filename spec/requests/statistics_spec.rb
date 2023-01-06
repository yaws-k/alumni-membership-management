require 'rails_helper'

RSpec.describe 'Statistics', type: :request do
  let(:user) { create(:user) }
  let(:member) { user.member }

  let!(:payment) { create(:event, :annual_fee, event_name: '年会費') }

  RSpec.shared_examples 'statistics members redirect' do
    it 'returns http success' do
      get '/statistics/members'
      expect(response).to redirect_to(destination)
    end
  end

  RSpec.shared_examples 'statistics members success' do
    it 'returns http success' do
      get '/statistics/members'
      expect(response).to have_http_status(:success)
    end
  end

  # Not logged in
  context 'not logged in' do
    let(:destination) { new_user_session_path }

    it_behaves_like 'statistics members redirect'
  end

  # Normal user
  context 'normal user' do
    before { sign_in user }
    let(:destination) { members_path }

    it_behaves_like 'statistics members redirect'
  end

  # Lead
  context 'lead' do
    before do
      member.update(roles: %w[lead])
      sign_in user
    end

    it_behaves_like 'statistics members success'
  end

  # Board
  context 'board' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    it_behaves_like 'statistics members success'
  end

  # Admin
  context 'admin' do
    before do
      member.update(roles: %w[admin])
      sign_in user
    end

    it_behaves_like 'statistics members success'
  end
end
