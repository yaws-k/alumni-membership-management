require 'rails_helper'

RSpec.describe 'Members', type: :request do
  let(:user) { create(:user) }

  # Not logged in
  context 'not logged in' do
    let(:member) { user.member }

    describe '#index' do
      it 'returns http redirect' do
        get '/members'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#show' do
      it 'returns http redirect' do
        get "/members/#{member.id}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/members/new'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post '/members'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        put "/members/#{member.id}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/members/#{member.id}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/members/#{member.id}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # Normal user
  context 'normal user' do
    let(:member) { user.member }

    describe '#index' do
      it 'returns http redirect' do
        sign_in user
        get '/members'
        expect(response).to redirect_to(member_path(member))
      end
    end

    describe '#show' do
      it 'returns http redirect' do
        sign_in user
        get "/members/#{member.id}"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        sign_in user
        get '/members/new'
        expect(response).to redirect_to(member_path(member))
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        sign_in user
        post '/members', params: {
          member: {
            family_name_phonetic: 'しんき',
            first_name_phonetic: 'なまえ',
            family_name: '新規',
            first_name: '名前',
            year_id: member.year.id
          }
        }
        expect(response).to redirect_to(member_path(member))
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        sign_in user
        get "/members/#{member.id}"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        sign_in user
        patch "/members/#{member.id}", params: {
          member: {
            family_name_phonetic: 'こうしん',
            family_name: '更新',
            roles: ['']
          }
        }
        expect(response).to redirect_to(member_path(member))
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        sign_in user
        delete "/members/#{member.id}"
        expect(response).to redirect_to(member_path(member))
      end
    end
  end

  # Lead
  context 'lead' do
    let(:member) { user.member.update(roles: %w[lead]) }

    describe '#index' do
      it 'returns http success' do
        user.member.update(roles: %w[lead])
        sign_in user
        get '/members'
        expect(response).to have_http_status(:success)
      end
    end
  end

  # Board
  context 'board member' do
    let(:member) { user.member.update(roles: %w[board]) }

    describe '#index' do
      it 'returns http success' do
        user.member.update(roles: %w[board])
        sign_in user
        get '/members'
        expect(response).to have_http_status(:success)
      end
    end
  end

  # Admin
  context 'admin' do
    let(:member) { user.member.update(roles: %w[admin]) }

    describe '#index' do
      it 'returns http success' do
        user.member.update(roles: %w[admin])
        sign_in user
        get '/members'
        expect(response).to have_http_status(:success)
      end
    end
  end
end
