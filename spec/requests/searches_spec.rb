require 'rails_helper'

RSpec.describe 'Searches', type: :request do
  let!(:user) { create(:user) }
  let!(:member) { user.member }

  let!(:payment) { create(:event, :annual_fee, event_name: '年会費') }

  RSpec.shared_examples 'searches reject' do
    it 'returns http redirect' do
      get '/searches/name?search=dummy&commit=%E6%B0%8F%E5%90%8D%E6%A4%9C%E7%B4%A2'
      expect(response).to redirect_to(destination)
    end

    it 'returns http redirect' do
      get '/searches/name?search=dummy&commit=%E3%83%A1%E3%83%BC%E3%83%AB%E6%A4%9C%E7%B4%A2'
      expect(response).to redirect_to(destination)
    end
  end

  RSpec.shared_examples 'searches accept' do
    it 'returns http redirect' do
      get '/searches/name?search=dummy&commit=%E6%B0%8F%E5%90%8D%E6%A4%9C%E7%B4%A2'
      expect(response).to have_http_status(:success)
    end

    it 'returns http redirect' do
      get '/searches/name?search=dummy&commit=%E3%83%A1%E3%83%BC%E3%83%AB%E6%A4%9C%E7%B4%A2'
      expect(response).to have_http_status(:success)
    end
  end

  # Not logged in
  context 'not logged in' do
    let(:destination) { new_user_session_path }

    it_behaves_like 'searches reject'
  end

  # Normal user
  context 'normal user' do
    before { sign_in user }
    let(:destination) { members_path }

    it_behaves_like 'searches reject'
  end

  # Lead
  context 'lead' do
    before do
      member.update(roles: %w[lead])
      sign_in user
    end

    it_behaves_like 'searches accept'
  end

  # Board
  context 'board' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    it_behaves_like 'searches accept'
  end

  # Admin
  context 'admin' do
    before do
      member.update(roles: %w[admin])
      sign_in user
    end

    it_behaves_like 'searches accept'
  end
end
