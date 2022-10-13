require 'rails_helper'

RSpec.describe 'Members', type: :request do
  let(:user) { create(:user) }

  describe '#index' do
    context 'not logged in' do
      it 'returns http redirect' do
        get '/members/index'
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'normal user' do
      it 'returns http redirect' do
        sign_in user
        get '/members'
        expect(response).to redirect_to member_path(user.member)
      end
    end

    context 'lead' do
      it 'returns http success' do
        user.member.update(roles: %w[lead])
        sign_in user
        get '/members'
        expect(response).to have_http_status(:success)
      end
    end

    context 'board member' do
      it 'returns http success' do
        user.member.update(roles: %w[board])
        sign_in user
        get '/members'
        expect(response).to have_http_status(:success)
      end
    end

    context 'admin' do
      it 'returns http success' do
        user.member.update(roles: %w[admin])
        sign_in user
        get '/members'
        expect(response).to have_http_status(:success)
      end
    end
  end
end
