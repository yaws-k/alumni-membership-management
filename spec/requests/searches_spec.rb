require 'rails_helper'

RSpec.describe 'Searches', type: :request do
  let!(:user) { create(:user) }
  let!(:member) { user.member }

  let!(:member1) { create(:member, year_id: member.year_id) }
  let!(:member2) { create(:member) }
  let!(:payment) { create(:event, :annual_fee, event_name: '年会費') }

  RSpec.shared_examples 'searches/name reject' do
    it 'returns http redirect' do
      get '/searches/name?search=dummy&commit=%E6%B0%8F%E5%90%8D%E6%A4%9C%E7%B4%A2'
      expect(response).to redirect_to(destination)
    end
  end

  RSpec.shared_examples 'searches/name accept' do
    it 'returns http redirect' do
      get '/searches/name?search=dummy&commit=%E6%B0%8F%E5%90%8D%E6%A4%9C%E7%B4%A2'
      expect(response).to have_http_status(:success)
    end
  end

  # Not logged in
  context 'not logged in' do
    let(:destination) { new_user_session_path }

    it_behaves_like 'searches/name reject'
  end

  # Normal user
  context 'normal user' do
    before { sign_in user }
    let(:destination) { members_path }

    it_behaves_like 'searches/name reject'
  end

  # Lead
  context 'lead' do
    before do
      member.update(roles: %w[lead])
      sign_in user
    end

    it_behaves_like 'searches/name accept'
  end

  # Board
  context 'board' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    it_behaves_like 'searches/name accept'
  end

  # Admin
  context 'admin' do
    before do
      member.update(roles: %w[admin])
      sign_in user
    end

    it_behaves_like 'searches/name accept'
  end
end
