require 'rails_helper'

RSpec.describe 'Members', type: :request do
  let(:user) { create(:user) }

  let(:create_member_param) do
    {
      family_name_phonetic: 'しんき',
      first_name_phonetic: 'なまえ',
      family_name: '新規',
      first_name: '名前',
      roles: ['']
    }
  end

  let(:edit_member_param) do
    {
      family_name_phonetic: 'こうしん',
      family_name: '更新',
      roles: ['']
    }
  end

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
    let(:member2) { create(:member, year_id: member.year_id) }

    describe '#index' do
      it 'returns http redirect' do
        sign_in user
        get '/members'
        expect(response).to redirect_to(member_path(member))
      end
    end

    describe '#show' do
      it 'returns http success for own data' do
        sign_in user
        get "/members/#{member.id}"
        expect(response).to have_http_status(:success)
      end

      it 'returns http redirect for other data' do
        sign_in user
        get "/members/#{member2.id}"
        expect(response).to redirect_to(members_path)
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
      it 'returns http redirect (reject)' do
        sign_in user
        post '/members', params: {
          member: create_member_param.merge(year_id: member.year_id)
        }
        expect(response).to redirect_to(member_path(member))
      end
    end

    describe '#edit' do
      it 'returns http success for own data' do
        sign_in user
        get "/members/#{member.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it 'returns http redirect for other data' do
        sign_in user
        get "/members/#{member2.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'returns http redirect to detailed page for own data' do
        sign_in user
        patch "/members/#{member.id}", params: { member: edit_member_param }
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect to members_path for other data' do
        sign_in user
        patch "/members/#{member2.id}", params: { member: edit_member_param }
        expect(response).to redirect_to(members_path)
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
    before do
      user.member.update(roles: %w[lead])
    end

    let(:member) { user.member }
    let(:member2) { create(:member, year_id: member.year_id) }
    let(:member3) { create(:member)}

    describe '#index' do
      it 'returns http success' do
        sign_in user
        get '/members'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#show' do
      it 'returns http success for own data' do
        sign_in user
        get "/members/#{member.id}"
        expect(response).to have_http_status(:success)
      end

      it 'returns http success for same year member data' do
        sign_in user
        get "/members/#{member2.id}"
        expect(response).to have_http_status(:success)
      end

      it 'returns http redirect for different year member data' do
        sign_in user
        get "/members/#{member3.id}"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#new' do
      it 'returns http success' do
        sign_in user
        get '/members/new'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#create' do
      it 'returns http redirect (succeed with same year)' do
        sign_in user
        post '/members', params: {
          member: create_member_param.merge(year_id: member.year_id)
        }
        expect(response).to redirect_to(member_path(Member.last))
      end

      it 'returns http redirect (rejecte with different year)' do
        sign_in user
        post '/members', params: {
          member: create_member_param.merge(year_id: member3.year_id)
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http success for own data' do
        sign_in user
        get "/members/#{member.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it 'returns http success with same year member data' do
        sign_in user
        get "/members/#{member2.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it 'returns http success with different year member data' do
        sign_in user
        get "/members/#{member3.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'returns http redirect to detailed page for own data' do
        sign_in user
        patch "/members/#{member.id}", params: { member: edit_member_param }
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect to detailed page for same year member data' do
        sign_in user
        patch "/members/#{member2.id}", params: { member: edit_member_param }
        expect(response).to redirect_to(member_path(member2))
      end

      it 'returns http redirect to members_path for different year member data' do
        sign_in user
        patch "/members/#{member3.id}", params: { member: edit_member_param }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        sign_in user
        delete "/members/#{member.id}"
        expect(response).to redirect_to(members_path)
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
