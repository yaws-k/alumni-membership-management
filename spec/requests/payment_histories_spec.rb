require 'rails_helper'

RSpec.describe 'PaymentHistories', type: :request do
  let(:user) { create(:user) }
  let(:member) { user.member }

  let(:payment) { create(:event, :payment) }
  let(:attendance) { create(:attendance, member_id: member.id, event_id: payment.id) }

  let(:create_payment_history_param) do
    {
      member_id: member.id,
      event_id: payment.id,
      payment_date: Date.today - 10,
      amount: 3000,
      note: '備考'
    }
  end

  let(:update_payment_history_param) do
    {
      payment_date: Date.today - 5,
      amount: 1000
    }
  end

  RSpec.shared_examples 'payment_histories reject' do
    it 'returns http redirect' do
      get "/payment_histories/new?member_id=#{member.id}"
      expect(response).to redirect_to(members_path)
    end

    it 'returns http redirect' do
      post '/payment_histories', params: { attendance: create_payment_history_param }
      expect(response).to redirect_to(members_path)
    end

    it 'returns http redirect' do
      get "/payment_histories/#{attendance.id}/edit"
      expect(response).to redirect_to(members_path)
    end

    it 'returns http redirect' do
      patch "/payment_histories/#{attendance.id}", params: { attendance: update_payment_history_param }
      expect(response).to redirect_to(members_path)
    end

    it 'returns http redirect' do
      delete "/payment_histories/#{attendance.id}"
      expect(response).to redirect_to(members_path)
    end
  end

  RSpec.shared_examples 'payment_histories accept' do
    it 'returns http success' do
      get "/payment_histories/new?member_id=#{member.id}"
      expect(response).to have_http_status(:success)
    end

    it 'returns http redirect' do
      post '/payment_histories', params: { attendance: create_payment_history_param }
      expect(response).to redirect_to(member_path(member.id, anchor: 'payment'))
    end

    it 'returns http success' do
      get "/payment_histories/#{attendance.id}/edit"
      expect(response).to have_http_status(:success)
    end

    it 'returns http redirect' do
      patch "/payment_histories/#{attendance.id}", params: { attendance: update_payment_history_param }
      expect(response).to redirect_to(member_path(member.id, anchor: 'payment'))
    end

    it 'returns http redirect' do
      delete "/payment_histories/#{attendance.id}"
      expect(response).to redirect_to(member_path(member.id, anchor: 'payment'))
    end
  end

  # Not logged in
  context 'not logged in' do
    it 'returns http redirect' do
      get "/payment_histories/new?member_id=#{member.id}"
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'returns http redirect' do
      post '/payment_histories', params: { attendance: create_payment_history_param }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'returns http redirect' do
      get "/payment_histories/#{attendance.id}/edit"
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'returns http redirect' do
      patch "/payment_histories/#{attendance.id}", params: { attendance: update_payment_history_param }
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'returns http redirect' do
      delete "/payment_histories/#{attendance.id}"
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  # Normal user
  context 'normal user' do
    before { sign_in user }

    it_behaves_like 'payment_histories reject'
  end

  # Lead
  context 'lead' do
    before do
      member.update(roles: %w[lead])
      sign_in user
    end

    it_behaves_like 'payment_histories reject'
  end

  # Board
  context 'board' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    it_behaves_like 'payment_histories accept'
  end

  # Admin
  context 'admin' do
    before do
      member.update(roles: %w[admin])
      sign_in user
    end

    it_behaves_like 'payment_histories accept'
  end
end
