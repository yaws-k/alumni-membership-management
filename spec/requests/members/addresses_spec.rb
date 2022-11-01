require 'rails_helper'

RSpec.describe 'Members::Addresses', type: :request do
  let(:user) { create(:user) }
  let(:member) { user.member }
  let(:address) { create(:address, member_id: member.id) }

  let(:member2) { create(:member, year_id: member.year_id) }
  let(:address2) { create(:address, member_id: member2.id) }

  let(:member3) { create(:member) }
  let(:address3) { create(:address, member_id: member3.id) }

  let(:create_address_param) do
    {
      postal_code: '100-0005',
      address1: '東京都千代田区丸の内1-9-1',
      address2: '東京駅',
      member_id: member.id
    }
  end

  let(:edit_address_param) do
    {
      postal_code: '100-0006',
      address1: '東京都千代田区有楽町2-9-17',
      address2: '有楽町駅',
    }
  end

  # Not logged in
  context 'not logged in' do
    describe '#new' do
      it 'returns http redirect' do
        get "/members/#{member.id}/addresses/new"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#create' do
      it 'returns http redirect' do
        post "/members/#{member.id}/addresses", params: {
          address: create_address_param
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#edit' do
      it 'returns http redirect' do
        get "/members/#{member.id}/addresses/#{address.id}/edit"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#update' do
      it 'returns http redirect' do
        patch "/members/#{member.id}/addresses/#{address.id}", params: {
          address: edit_address_param
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe '#destroy' do
      it 'returns http redirect' do
        delete "/members/#{member.id}/addresses/#{address.id}"
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
        get "/members/#{member.id}/addresses/new"
        expect(response).to have_http_status(:success)
      end

      it 'returns http redirect to others data' do
        get "/members/#{member2.id}/addresses/new"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it 'returns http redirect to own data (success)' do
        post "/members/#{member.id}/addresses", params: {
          address: create_address_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it 'returns http redirect to own data (reject)' do
        post "/members/#{member2.id}/addresses", params: {
          address: create_address_param
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http success to own data' do
        get "/members/#{member.id}/addresses/#{address.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to other member's data" do
        get "/members/#{member2.id}/addresses/#{address.id}/edit"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect to other member's address data" do
        get "/members/#{member.id}/addresses/#{address2.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'retuns http redirect to own data (success)' do
        patch "/members/#{member.id}/addresses/#{address.id}", params: {
          address: edit_address_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it "returns http redirect to other member's data" do
        patch "/members/#{member2.id}/addresses/#{address.id}", params: {
          address: edit_address_param
        }
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect to other member's address data" do
        patch "/members/#{member.id}/addresses/#{address2.id}", params: {
          address: edit_address_param
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'retuns http redirect to own data (success)' do
        delete "/members/#{member.id}/addresses/#{address.id}"
        expect(response).to redirect_to(member_path(member))
      end

      it "returns http redirect to other member's data" do
        delete "/members/#{member2.id}/addresses/#{address.id}"
        expect(response).to redirect_to(members_path)
      end

      it "returns http redirect to other member's address data" do
        delete "/members/#{member.id}/addresses/#{address2.id}"
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
        get "/members/#{member.id}/addresses/new"
        expect(response).to have_http_status(:success)
      end

      it "returns http succss to same year member's data" do
        get "/members/#{member2.id}/addresses/new"
        expect(response).to have_http_status(:success)
      end

      it 'returns http redirect to others data' do
        get "/members/#{member3.id}/addresses/new"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#create' do
      it 'returns http redirect to own data (success)' do
        post "/members/#{member.id}/addresses", params: {
          address: create_address_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it "returns http redirect to same year member's data (success)" do
        post "/members/#{member2.id}/addresses", params: {
          address: create_address_param
        }
        expect(response).to redirect_to(member_path(member2))
      end

      it 'returns http redirect (reject) to others data' do
        post "/members/#{member3.id}/addresses", params: {
          address: create_address_param
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#edit' do
      it 'returns http success to own data' do
        get "/members/#{member.id}/addresses/#{address.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http success to same year member's data" do
        get "/members/#{member2.id}/addresses/#{address2.id}/edit"
        expect(response).to have_http_status(:success)
      end

      it "returns http redirect to other member's address data" do
        get "/members/#{member3.id}/addresses/#{address3.id}/edit"
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#update' do
      it 'retuns http redirect to own data (success)' do
        patch "/members/#{member.id}/addresses/#{address.id}", params: {
          address: edit_address_param
        }
        expect(response).to redirect_to(member_path(member))
      end

      it "returns http redirect (success) to same year member's data" do
        patch "/members/#{member2.id}/addresses/#{address2.id}", params: {
          address: edit_address_param
        }
        expect(response).to redirect_to(member_path(member2))
      end

      it "returns http redirect (reject) to other member's address data" do
        patch "/members/#{member3.id}/addresses/#{address3.id}", params: {
          address: edit_address_param
        }
        expect(response).to redirect_to(members_path)
      end
    end

    describe '#destroy' do
      it 'retuns http redirect to own data (success)' do
        delete "/members/#{member.id}/addresses/#{address.id}"
        expect(response).to redirect_to(member_path(member))
      end

      it "returns http redirect (success) to same year member's data" do
        delete "/members/#{member2.id}/addresses/#{address2.id}"
        expect(response).to redirect_to(member_path(member2))
      end

      it "returns http redirect (reject) to other member's address data" do
        delete "/members/#{member3.id}/addresses/#{address3.id}"
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
  end

  # Admin
  context 'admin' do
    # The same as board member.
    # Details should be tested with system specs.
  end
end
