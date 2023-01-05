require 'rails_helper'

RSpec.describe 'Mails', type: :request do
  let!(:user) { create(:user) }
  let!(:member) { user.member }

  let!(:member1) { create(:member, year_id: member.year_id) }
  let!(:member2) { create(:member) }

  # Not logged in
  context 'not logged in' do
    describe '#index' do
      it 'returns http redirect' do
        get '/mails'
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # Normal user
  context 'normal user' do
    before do
      sign_in user
    end

    describe '#index' do
      it 'returns http redirect' do
        get '/mails'
        expect(response).to redirect_to(members_path)
      end
    end
  end

  # Lead
  context 'lead' do
    before do
      member.update(roles: %w[lead])
      sign_in user
    end

    describe '#index' do
      it 'returns http success' do
        get '/mails'
        expect(response).to have_http_status(:success)
      end
    end
  end

  # Board
  context 'board' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    describe '#index' do
      it 'returns http success' do
        get '/mails'
        expect(response).to have_http_status(:success)
      end
    end
  end

  # Admin
  context 'admin' do
    before do
      member.update(roles: %w[admin])
      sign_in user
    end

    describe '#index' do
      it 'returns http success' do
        get '/mails'
        expect(response).to have_http_status(:success)
      end
    end
  end
end
