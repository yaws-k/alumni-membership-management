require 'rails_helper'

RSpec.describe 'Statistics', type: :request do
  let!(:user) { create(:user) }
  let!(:member) { user.member }

  let!(:annual_fee) { create(:event, :annual_fee, event_name: '年会費') }
  let!(:donation) { create(:event, :payment) }

  let!(:member1) { create(:member) }
  let!(:attendance1) { create(:attendance, member_id: member1.id, event_id: annual_fee.id, payment_date: (Date.today - 1), amount: 3000) }

  let!(:member2) { create(:member) }
  let!(:attendance2) { create(:attendance, member_id: member2.id, event_id: donation.id, payment_date: (Date.today - 2), amount: 1000) }

  RSpec.shared_examples 'statistics members redirect' do
    it 'returns http redirect' do
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

  RSpec.shared_examples 'statistics incomes redirect' do
    it 'returns http redirect' do
      get '/statistics/incomes'
      expect(response).to redirect_to(destination)
    end

    it 'returns http redirect' do
      get '/statistics/annual_fees'
      expect(response).to redirect_to(destination)
    end
  end

  RSpec.shared_examples 'statistics incomes success' do
    it 'returns http success' do
      get '/statistics/incomes'
      expect(response).to have_http_status(:success)
    end

    it 'returns http success' do
      get '/statistics/annual_fees'
      expect(response).to have_http_status(:success)
    end
  end

  # Not logged in
  context 'not logged in' do
    let(:destination) { new_user_session_path }

    it_behaves_like 'statistics members redirect'
    it_behaves_like 'statistics incomes redirect'
  end

  # Normal user
  context 'normal user' do
    before { sign_in user }
    let(:destination) { members_path }

    it_behaves_like 'statistics members redirect'
    it_behaves_like 'statistics incomes redirect'
  end

  # Lead
  context 'lead' do
    before do
      member.update(roles: %w[lead])
      sign_in user
    end
    let(:destination) { members_path }

    it_behaves_like 'statistics members success'
    it_behaves_like 'statistics incomes redirect'
  end

  # Board
  context 'board' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    it_behaves_like 'statistics members success'
    it_behaves_like 'statistics incomes success'
  end

  # Admin
  context 'admin' do
    before do
      member.update(roles: %w[admin])
      sign_in user
    end

    it_behaves_like 'statistics members success'
    it_behaves_like 'statistics incomes success'
  end
end
