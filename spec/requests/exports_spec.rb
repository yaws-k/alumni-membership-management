require 'rails_helper'

RSpec.describe 'Exports', type: :request do
  let!(:user) { create(:user) }
  let!(:member) { user.member }

  let!(:member1) { create(:member, year_id: member.year_id) }
  let!(:member2) { create(:member) }
  let!(:payment) { create(:event, :annual_fee, event_name: '年会費') }

  RSpec.shared_examples 'exports/members reject' do
    it 'returns http redirect' do
      get '/exports/members'
      expect(response).to redirect_to(destination)
    end
  end

  RSpec.shared_examples 'exports/members accept' do
    it 'returns http redirect' do
      get '/exports/members'
      expect(response).to have_http_status(:success)
    end
  end

  # Not logged in
  context 'not logged in' do
    let(:destination) { new_user_session_path }

    it_behaves_like 'exports/members reject'
  end

  # Normal user
  context 'normal user' do
    before { sign_in user }
    let(:destination) { members_path }

    it_behaves_like 'exports/members reject'
  end

  # Lead
  context 'lead' do
    before do
      member.update(roles: %w[lead])
      sign_in user
    end

    it_behaves_like 'exports/members accept'
  end

  # Board
  context 'board' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    it_behaves_like 'exports/members accept'
  end

  # Admin
  context 'admin' do
    before do
      member.update(roles: %w[admin])
      sign_in user
    end

    it_behaves_like 'exports/members accept'
  end
end
