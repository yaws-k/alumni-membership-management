require 'rails_helper'

RSpec.describe 'Members', type: :request do
  let(:user) { create(:user) }
  let(:member) { user.member }
  let(:member2) { create(:member, year_id: member.year_id) }
  let(:member3) { create(:member) }
  let!(:payment) { create(:event, :payment, event_name: '年会費') }

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
        post '/members', params: {
          member: create_member_param
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/members/#{member.id}/edit"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/members/#{member.id}", params: {
          member: edit_member_param
        }
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
    before do
      sign_in user
    end

    describe '#index' do
      it 'returns http redirect' do
        get '/members'
        expect(response).to redirect_to(member_path(member))
      end
    end

    describe '#show' do
      it 'returns http success to own data' do
        get "/members/#{member.id}"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to same year member's data" do
        get "/members/#{member2.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect to other member's data" do
        get "/members/#{member3.id}"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#new' do
      it 'returns http redirect' do
        get '/members/new'
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it "returns http redirect (reject) to same year member's data" do
        post '/members', params: {
          member: create_member_param.merge(year_id: member.year_id)
        }
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to other member's data" do
        post '/members', params: {
          member: create_member_param.merge(year_id: member3.year_id)
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http success to own data' do
        get "/members/#{member.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to same year member's data" do
        get "/members/#{member2.id}/edit"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect to other member's data" do
        get "/members/#{member3.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'retuns http redirect (success) to own data' do
        patch "/members/#{member.id}", params: {
          member: edit_member_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it "returns http redirect (reject) to same year member's data" do
        patch "/members/#{member2.id}", params: {
          member: edit_member_param
        }
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to other member's data" do
        patch "/members/#{member3.id}", params: {
          member: edit_member_param
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'retuns http redirect (reject) to own data' do
        delete "/members/#{member.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to same year member's data" do
        delete "/members/#{member2.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to other member's data" do
        delete "/members/#{member3.id}"
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
        get '/members'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#show' do
      it 'returns http success to own data' do
        get "/members/#{member.id}"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to same year member's data" do
        get "/members/#{member2.id}"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to other member's data" do
        get "/members/#{member3.id}"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#new' do
      it 'returns http success' do
        get '/members/new'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#create' do
      it "returns http redirect (success) to same year member's data" do
        post '/members', params: {
          member: create_member_param.merge(year_id: member.year_id)
        }
        expect(response).to redirect_to(member_path(Member.last))
      end

      it "returns http redirect (reject) to other member's data" do
        post '/members', params: {
          member: create_member_param.merge(year_id: member3.year_id)
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http success to own data' do
        get "/members/#{member.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http success to same year member's data" do
        get "/members/#{member2.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to other member's data" do
        get "/members/#{member3.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'retuns http redirect (success) to own data' do
        patch "/members/#{member.id}", params: {
          member: edit_member_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it "returns http redirect (success) to same year member's data" do
        patch "/members/#{member2.id}", params: {
          member: edit_member_param
        }
        expect(response).to redirect_to(member_path(member2))
      end

      it "returns http redirect (reject) to other member's data" do
        patch "/members/#{member3.id}", params: {
          member: edit_member_param
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'retuns http redirect (reject) to own data' do
        delete "/members/#{member.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to same year member's data" do
        delete "/members/#{member2.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to other member's data" do
        delete "/members/#{member3.id}"
        expect(response).to redirect_to(members_path)
      end
    end
  end

  # Board
  context 'board member' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    describe '#index' do
      it 'returns http success' do
        get '/members'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#show' do
      it 'returns http success to own data' do
        get "/members/#{member.id}"
        expect(response).to have_http_status(:success)
      end

      it "returns http success to same year member's data" do
        get "/members/#{member2.id}"
        expect(response).to have_http_status(:success)
      end

      it "returns http success to other member's data" do
        get "/members/#{member3.id}"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#new' do
      it 'returns http success' do
        get '/members/new'
        expect(response).to have_http_status(:success)
      end
    end

    describe '#create' do
      it "returns http redirect (success) to same year member's data" do
        post '/members', params: {
          member: create_member_param.merge(year_id: member.year_id)
        }
        expect(response).to redirect_to(member_path(Member.last))
      end

      it "returns http redirect (success) to other member's data" do
        post '/members', params: {
          member: create_member_param.merge(year_id: member3.year_id)
        }
        expect(response).to redirect_to(member_path(Member.last))
      end
    end

    describe '#edit' do
      it 'returns http success to own data' do
        get "/members/#{member.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http success to same year member's data" do
        get "/members/#{member2.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http success to other member's data" do
        get "/members/#{member3.id}/edit"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#update' do
      it 'retuns http redirect (success) to own data' do
        patch "/members/#{member.id}", params: {
          member: edit_member_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it "returns http redirect (success) to same year member's data" do
        patch "/members/#{member2.id}", params: {
          member: edit_member_param
        }
        expect(response).to redirect_to(member_path(member2))
      end

      it "returns http redirect (success) to other member's data" do
        patch "/members/#{member3.id}", params: {
          member: edit_member_param
        }
        expect(response).to redirect_to(member_path(member3))
      end
    end

    describe '#destroy' do
      it 'retuns http redirect (success) to own data' do
        delete "/members/#{member.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (success) to same year member's data" do
        delete "/members/#{member2.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (success) to other member's data" do
        delete "/members/#{member3.id}"
        expect(response).to redirect_to(members_path)
      end
    end
  end

  # Admin
  context 'admin' do
    # The same as board member.
    # Details should be tested with system specs.
  end
end
