require 'rails_helper'

RSpec.describe "Members::Users", type: :request do
  let(:user) { create(:user) }
  let(:member) { user.member }

  let(:member2) { create(:member, year_id: member.year_id) }
  let(:user2) { create(:user, member_id: member2.id) }

  let(:user3) { create(:user) }
  let(:member3) { user3.member }

  let(:create_user_param) do
    {
      email: 'create@example.com',
      password: 'password',
      password_confirmation: 'password'
    }
  end

  let(:edit_user_param) do
    {
      email: 'edit@example.com'
    }
  end

  # Not logged in
  context 'not logged in' do
    describe '#new' do
      it 'returns http redirect' do
        get "/members/#{member.id}/users/new"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post "/members/#{member.id}/users", params: {
          user: create_user_param
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/members/#{member.id}/users/#{user.id}/edit"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/members/#{member.id}/users/#{user.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/members/#{member.id}/users/#{user.id}"
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # Normal user
  context 'normal user' do
    before do
      sign_in user
    end

    describe '#new' do
      it 'returns http success to own data' do
        get "/members/#{member.id}/users/new"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to same year member's data" do
        get "/members/#{member2.id}/users/new"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect to other member's data" do
        get "/members/#{member3.id}/users/new"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it 'returns http redirect (success) to own data' do
        post "/members/#{member.id}/users", params: {
          user: create_user_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect (reject) to same year member data' do
        post "/members/#{member2.id}/users", params: {
          user: create_user_param
        }
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to other member's data" do
        post "/members/#{member3.id}/users", params: {
          user: create_user_param
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http success to own data' do
        get "/members/#{member.id}/users/#{user.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it 'returns http redirect to inconsistent url' do
        get "/members/#{member2.id}/users/#{user.id}/edit"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect to same year member's data" do
        get "/members/#{member2.id}/users/#{user2.id}/edit"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect to other member's data" do
        get "/members/#{member3.id}/users/#{user3.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'retuns http redirect (success) to own data' do
        patch "/members/#{member.id}/users/#{user.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect to inconsistent url' do
        patch "/members/#{member2.id}/users/#{user.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to same year member's data" do
        patch "/members/#{member2.id}/users/#{user2.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to other member's data" do
        patch "/members/#{member3.id}/users/#{user3.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'retuns http redirect (success) to own data' do
        delete "/members/#{member.id}/users/#{user.id}"
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect (reject) to inconsistent url' do
        delete "/members/#{member2.id}/users/#{user.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to same year member's data" do
        delete "/members/#{member2.id}/users/#{user2.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (reject) to other member's data" do
        delete "/members/#{member3.id}/users/#{user3.id}"
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

    describe '#new' do
      it 'returns http success to own data' do
        get "/members/#{member.id}/users/new"
        expect(response).to have_http_status(:success)
      end

      it "returns http succss to same year member's data" do
        get "/members/#{member2.id}/users/new"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to other member's data" do
        get "/members/#{member3.id}/users/new"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it 'returns http redirect (success) to own data' do
        post "/members/#{member.id}/users", params: {
          user: create_user_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect (success) to same year member data' do
        post "/members/#{member2.id}/users", params: {
          user: create_user_param
        }
        expect(response).to redirect_to(member_path(member2))
      end

      it "returns http redirect (reject) to other member's data" do
        post "/members/#{member3.id}/users", params: {
          user: create_user_param
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http success to own data' do
        get "/members/#{member.id}/users/#{user.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it 'returns http redirect to inconsistent url' do
        get "/members/#{member2.id}/users/#{user.id}/edit"
        expect(response).to redirect_to(members_path)
      end

      it "returns http success to same year member's data" do
        get "/members/#{member2.id}/users/#{user2.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to other member's data" do
        get "/members/#{member3.id}/users/#{user3.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'retuns http redirect (success) to own data' do
        patch "/members/#{member.id}/users/#{user.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect to inconsistent url' do
        patch "/members/#{member2.id}/users/#{user.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (success) to same year member's data" do
        patch "/members/#{member2.id}/users/#{user2.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(member_path(member2))
      end

      it "returns http redirect (reject) to other member's data" do
        patch "/members/#{member3.id}/users/#{user3.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'retuns http redirect (success) to own data' do
        delete "/members/#{member.id}/users/#{user.id}"
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect (reject) to inconsistent url' do
        delete "/members/#{member2.id}/users/#{user.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (success) to same year member's data" do
        delete "/members/#{member2.id}/users/#{user2.id}"
        expect(response).to redirect_to(member_path(member2))
      end

      it "returns http redirect (reject) to other member's data" do
        delete "/members/#{member3.id}/users/#{user3.id}"
        expect(response).to redirect_to(members_path)
      end
    end
  end

  # Board
  context 'lead' do
    before do
      member.update(roles: %w[board])
      sign_in user
    end

    describe '#new' do
      it 'returns http success to own data' do
        get "/members/#{member.id}/users/new"
        expect(response).to have_http_status(:success)
      end

      it "returns http succss to same year member's data" do
        get "/members/#{member2.id}/users/new"
        expect(response).to have_http_status(:success)
      end

      it "returns http succss to other member's data" do
        get "/members/#{member3.id}/users/new"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#create' do
      it 'returns http redirect (success) to own data' do
        post "/members/#{member.id}/users", params: {
          user: create_user_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect (success) to same year member data' do
        post "/members/#{member2.id}/users", params: {
          user: create_user_param
        }
        expect(response).to redirect_to(member_path(member2))
      end

      it "returns http redirect (success) to other member's data" do
        post "/members/#{member3.id}/users", params: {
          user: create_user_param
        }
        expect(response).to redirect_to(member_path(member3))
      end
    end

    describe '#edit' do
      it 'returns http success to own data' do
        get "/members/#{member.id}/users/#{user.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it 'returns http redirect to inconsistent url' do
        get "/members/#{member2.id}/users/#{user.id}/edit"
        expect(response).to redirect_to(members_path)
      end

      it "returns http success to same year member's data" do
        get "/members/#{member2.id}/users/#{user2.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to other member's data" do
        get "/members/#{member3.id}/users/#{user3.id}/edit"
        expect(response).to have_http_status(:success)
      end
    end

    describe '#update' do
      it 'retuns http redirect (success) to own data' do
        patch "/members/#{member.id}/users/#{user.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect to inconsistent url' do
        patch "/members/#{member2.id}/users/#{user.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (success) to same year member's data" do
        patch "/members/#{member2.id}/users/#{user2.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(member_path(member2))
      end

      it "returns http redirect (success) to other member's data" do
        patch "/members/#{member3.id}/users/#{user3.id}", params: {
          user: edit_user_param
        }
        expect(response).to redirect_to(member_path(member3))
      end
    end

    describe '#destroy' do
      it 'retuns http redirect (success) to own data' do
        delete "/members/#{member.id}/users/#{user.id}"
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect (reject) to inconsistent url' do
        delete "/members/#{member2.id}/users/#{user.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect (success) to same year member's data" do
        delete "/members/#{member2.id}/users/#{user2.id}"
        expect(response).to redirect_to(member_path(member2))
      end

      it "returns http redirect (success) to other member's data" do
        delete "/members/#{member3.id}/users/#{user3.id}"
        expect(response).to redirect_to(member_path(member3))
      end
    end
  end

  # Admin
  context 'admin' do
    # The same as board member.
    # Details should be tested with system specs.
  end
end
